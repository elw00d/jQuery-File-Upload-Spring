package su.elwood;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.util.Assert;
import org.springframework.util.FileCopyUtils;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.multipart.MultipartHttpServletRequest;

import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.*;

/**
 * @author igor.kostromin
 *         26.09.2014 23:13
 */
@Controller
public class UploadController {
    @RequestMapping(value = "/", method = RequestMethod.GET)
    public String viewIndex() {
        return "index";
    }

    public static class UploadResult {
        public List<FileMeta> files;

        public UploadResult(List<FileMeta> files) {
            this.files = files;
        }
    }

    /**
     * JSON-объект, ожидаемый контролом jQuery-File-Upload в качестве результата
     * операций GET /upload и POST /upload.
     */
    @JsonIgnoreProperties({"bytes"})
    public static  class FileMeta {
        public String name;
        public long size;
        public String url;
        public String thumbnailUrl;
        public String deleteUrl;
        public String deleteType = "DELETE";

        public byte[] bytes;
    }

    LinkedList<FileMeta> files = new LinkedList<>();
    FileMeta fileMeta = null;

    /**
     * Возвращает список всех прикреплённых файлов. Вызывается со стороны страницы один раз,
     * при инициализации контрола jQuery-File-Upload, далее состояние контрол поддерживает сам.
     * @return JSON-объект - список файлов.
     */
    @RequestMapping(value="/upload", method = RequestMethod.GET)
    public @ResponseBody UploadResult uploadGet() {
        return new UploadResult(files);
    }

    public static class DeleteResult {
        public List<Map<String, Boolean>> files;
    }

    /**
     * Удаляет выбранный уже загруженный файл из списка прикрепляемых.
     * Должен вернуть JSON вида
     * { files: [
     *     { "fileName" : true }
     *   ]
     * }
     * todo : delete not by name, use unique identity
     */
    @RequestMapping(value = "/delete", method = RequestMethod.DELETE)
    public synchronized @ResponseBody DeleteResult delete(@RequestParam String name) {
        List<FileMeta> toRemove = new ArrayList<>();
        for (FileMeta file : files) {
            if (file.name.equals(name))
                toRemove.add(file);
        }
        for (FileMeta file : toRemove) {
            files.remove(file);
        }

        DeleteResult result = new DeleteResult();
        result.files = new ArrayList<>();
        HashMap<String, Boolean> deletedFile = new HashMap<>();
        deletedFile.put("name", true);
        result.files.add(deletedFile);
        return result;
    }

    /**
     * Основной метод загрузки файлов. Возвращает JSON со списком файлов, добавленных
     * этим запросом (а не всех файлов, как GET /upload).
     */
    @RequestMapping(value = "/upload", method = RequestMethod.POST)
    @ResponseBody
    public synchronized UploadResult upload(MultipartHttpServletRequest request) {
        Iterator<String> itr = request.getFileNames();
        MultipartFile mpf = null;

        List<FileMeta> addedFiles = new ArrayList<>();
        while (itr.hasNext()) {
            mpf = request.getFile(itr.next());
            System.out.println(mpf.getOriginalFilename() + " uploaded! " + files.size());

            fileMeta = new FileMeta();
            fileMeta.name = mpf.getOriginalFilename();
            fileMeta.size = mpf.getSize();
            fileMeta.deleteUrl = request.getContextPath() + "/delete?name=" + fileMeta.name;
            fileMeta.thumbnailUrl = request.getContextPath() + "/get?name=" + fileMeta.name;
            fileMeta.url = request.getContextPath() + "/get?name=" + fileMeta.name;

            try {
                fileMeta.bytes = mpf.getBytes();

                // copy file to local disk (make sure the path "e.g. D:/temp/files" exists)
                //FileCopyUtils.copy(mpf.getBytes(), new FileOutputStream("D:/temp/files/"+mpf.getOriginalFilename()));

            } catch (IOException e) {
                // TODO Auto-generated catch block
                e.printStackTrace();
            }
            addedFiles.add(fileMeta);
            files.add(fileMeta);
        }
        return new UploadResult(addedFiles);
    }

    /**
     * Скачивание загруженного файла - для показа его в галерее.
     * @param name
     * @return
     */
    @RequestMapping(value = "/get", method = RequestMethod.GET)
    @ResponseBody
    public ResponseEntity get(@RequestParam String name, HttpServletResponse response) {
        FileMeta file = null;
		for (FileMeta candidate : files ) {
			if (candidate.name.equals(name)) {
				file = candidate;
				break;
			}
		}
        if (file == null) {
            return new ResponseEntity(HttpStatus.NOT_FOUND);
        }

        try {
            //response.setContentType(file.getFileType());
            //response.setHeader("Content-disposition", "attachment; filename=\""+getFile.name+"\"");
            FileCopyUtils.copy(file.bytes, response.getOutputStream());
        } catch (IOException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
        return new ResponseEntity(HttpStatus.OK);
    }
}

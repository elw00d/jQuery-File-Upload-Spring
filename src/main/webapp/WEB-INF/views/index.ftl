<!DOCTYPE html>
<html lang="ru">
<head>
    <#assign resources="${rc.contextPath}/resources"/>
    <meta charset="utf-8"/>
    <link href="${resources}/bootstrap/css/bootstrap.css" rel="stylesheet"/>

    <!-- blueimp Gallery styles -->
    <link href="${resources}/jquery-upload/dependencies/blueimp-gallery.min.css" rel="stylesheet"/>
    
    <!-- CSS to style the file input field as button and adjust the Bootstrap progress bars -->
    <link href="${resources}/jquery-upload/jquery.fileupload.css" rel="stylesheet"/>
    <link href="${resources}/jquery-upload/jquery.fileupload-ui.css" rel="stylesheet"/>

    <script src="${resources}/jquery-1.11.1.min.js" type="text/javascript"></script>
    <script src="${resources}/bootstrap/js/bootstrap.js" type="text/javascript"></script>
    <script src="${resources}/jquery-upload/jquery.ui.widget.js" type="text/javascript"></script>
    <script src="${resources}/jquery-upload/dependencies/load-image.all.min.js" type="text/javascript"></script>
    <script src="${resources}/jquery-upload/dependencies/tmpl.min.js" type="text/javascript"></script>
    <script src="${resources}/jquery-upload/dependencies/jquery.blueimp-gallery.min.js" type="text/javascript"></script>
    <script src="${resources}/jquery-upload/dependencies/canvas-to-blob.min.js" type="text/javascript"></script>
    <script src="${resources}/jquery-upload/jquery.fileupload.js" type="text/javascript"></script>
    <script src="${resources}/jquery-upload/jquery.fileupload-ui.js" type="text/javascript"></script>
    <script src="${resources}/jquery-upload/jquery.iframe-transport.js" type="text/javascript"></script>
    <script src="${resources}/jquery-upload/jquery.fileupload-process.js" type="text/javascript"></script>
    <script src="${resources}/jquery-upload/jquery.postmessage-transport.js" type="text/javascript"></script>
    <script src="${resources}/jquery-upload/jquery.fileupload-image.js" type="text/javascript"></script>
    <script src="${resources}/jquery-upload/jquery.fileupload-validate.js" type="text/javascript"></script>
</head>
<body>
    <div class="container">
    <h1 class="col-md-offset-2">Загрузка файлов</h1>

    <!-- The file upload form used as target for the file upload widget -->
    <form id="fileupload" method="POST" enctype="multipart/form-data">
        <!-- The fileupload-buttonbar contains buttons to add/delete files and start/cancel the upload -->
        <div class="row fileupload-buttonbar">
            <div class="col-lg-7">
                <!-- The fileinput-button span is used to style the file input field as button -->
                <span class="btn btn-success fileinput-button">
                    <i class="glyphicon glyphicon-plus"></i>
                    <span>Выбрать файлы...</span>
                    <input type="file" name="files[]" multiple>
                </span>
                <button type="submit" class="btn btn-primary start">
                    <i class="glyphicon glyphicon-upload"></i>
                    <span>Загрузить все</span>
                </button>
                <button type="reset" class="btn btn-warning cancel">
                    <i class="glyphicon glyphicon-ban-circle"></i>
                    <span>Отмена</span>
                </button>
                <button type="button" class="btn btn-danger delete">
                    <i class="glyphicon glyphicon-trash"></i>
                    <span>Удалить</span>
                </button>
                <input type="checkbox" class="toggle">
                <!-- The global file processing state -->
                <span class="fileupload-process"></span>
            </div>
            <!-- The global progress state -->
            <div class="col-lg-5 fileupload-progress fade">
                <!-- The global progress bar -->
                <div class="progress progress-striped active" role="progressbar" aria-valuemin="0" aria-valuemax="100">
                    <div class="progress-bar progress-bar-success" style="width:0%;"></div>
                </div>
                <!-- The extended global progress state -->
                <div class="progress-extended">&nbsp;</div>
            </div>
        </div>
        <!-- The table listing the files available for upload/download -->
        <table id="filesTable" role="presentation" class="table table-striped"><tbody class="files"></tbody></table>
    </form>

    <!-- The blueimp Gallery widget -->
    <div id="blueimp-gallery" class="blueimp-gallery blueimp-gallery-controls" data-filter=":even">
        <div class="slides"></div>
        <h3 class="title"></h3>
        <a class="prev">‹</a>
        <a class="next">›</a>
        <a class="close">×</a>
        <a class="play-pause"></a>
        <ol class="indicator"></ol>
    </div>

    <!-- The template to display files available for upload -->
    <script id="template-upload" type="text/x-tmpl">
    {% for (var i=0, file; file=o.files[i]; i++) { %}
        <tr class="template-upload fade">
            <td>
                <span class="preview"></span>
            </td>
            <td>
                <p class="name">{%=file.name%}</p>
                <strong class="error text-danger"></strong>
            </td>
            <td>
                <p class="size">Processing...</p>
                <div class="progress progress-striped active" role="progressbar" aria-valuemin="0" aria-valuemax="100" aria-valuenow="0"><div class="progress-bar progress-bar-success" style="width:0%;"></div></div>
            </td>
            <td>
                {% if (!i && !o.options.autoUpload) { %}
                    <button class="btn btn-primary start" disabled>
                        <i class="glyphicon glyphicon-upload"></i>
                        <span>Загрузить</span>
                    </button>
                {% } %}
                {% if (!i) { %}
                    <button class="btn btn-warning cancel">
                        <i class="glyphicon glyphicon-ban-circle"></i>
                        <span>Отмена</span>
                    </button>
                {% } %}
            </td>
        </tr>
    {% } %}
    </script>
    <!-- The template to display files available for download -->
    <script id="template-download" type="text/x-tmpl">
    {% for (var i=0, file; file=o.files[i]; i++) { %}
        <tr class="template-download fade">
            <td>
                <span class="preview">
                    {% if (file.thumbnailUrl) { %}
                        <a href="{%=file.url%}" title="{%=file.name%}" download="{%=file.name%}" data-gallery><img width="100" src="{%=file.thumbnailUrl%}"></a>
                    {% } %}
                </span>
            </td>
            <td>
                <p class="name">
                    {% if (file.url) { %}
                        <a href="{%=file.url%}" title="{%=file.name%}" download="{%=file.name%}" {%=file.thumbnailUrl?'data-gallery':''%}>{%=file.name%}</a>
                    {% } else { %}
                        <span>{%=file.name%}</span>
                    {% } %}
                </p>
                {% if (file.error) { %}
                    <div><span class="label label-danger">Error</span> {%=file.error%}</div>
                {% } %}
            </td>
            <td>
                <span class="size">{%=o.formatFileSize(file.size)%}</span>
            </td>
            <td>
                {% if (file.deleteUrl) { %}
                    <button class="btn btn-danger delete" data-type="{%=file.deleteType%}" data-url="{%=file.deleteUrl%}"{% if (file.deleteWithCredentials) { %} data-xhr-fields='{"withCredentials":true}'{% } %}>
                        <i class="glyphicon glyphicon-trash"></i>
                        <span>Удалить</span>
                    </button>
                    <input type="checkbox" name="delete" value="1" class="toggle">
                {% } else { %}
                    <button class="btn btn-warning cancel">
                        <i class="glyphicon glyphicon-ban-circle"></i>
                        <span>Отмена</span>
                    </button>
                {% } %}
            </td>
        </tr>
    {% } %}
    </script>

<script>
    $(function () {
        'use strict';

        // Initialize the jQuery File Upload widget:
        $('#fileupload').fileupload({
            url: '${rc.contextPath}/upload'
        });

        $('#fileupload').fileupload('option', {
            // Enable image resizing, except for Android and Opera,
            // which actually support image resizing, but fail to
            // send Blob objects via XHR requests:
            disableImageResize: /Android(?!.*Chrome)|Opera/
                .test(window.navigator.userAgent),
            maxFileSize: 5000000,
            acceptFileTypes: /(\.|\/)(gif|jpe?g|png)$/i
        });

        // Load existing files:
        $('#fileupload').addClass('fileupload-processing');
        $.ajax({
            url: $('#fileupload').fileupload('option', 'url'),
            dataType: 'json',
            context: $('#fileupload')[0]
        }).always(function () {
            $(this).removeClass('fileupload-processing');
        }).done(function (result) {
            $(this).fileupload('option', 'done')
                .call(this, $.Event('done'), {result: result});
        });
    });
</script>

</div>
</body>
</html>
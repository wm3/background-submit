HTMLのフォームを画面遷移無しで送信します。

```javascript
var form = document.querySelector('form');
var multipart = SubmitMultipart.activate(form);

multipart.submit();
```

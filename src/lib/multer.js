const multer = require('multer');
const path =  require('path');
//send
const storage =  multer.diskStorage({
    destination: path.join(__dirname, '../public/uploads'),
    filename: (req, file, cb) => {
        if (file) {
            cb(null, file.originalname.toLowerCase());
        } else {
            cb(null, 'default.png');
        }
    }
});
const upload =  multer({
    storage,
    dest: path.join(__dirname, '../public/uploads')
})

module.exports = upload;
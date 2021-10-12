const bcrypt = require('bcryptjs');

const helepers = {};


helepers.encryptPassword = async (password) => {
    const salt = bcrypt.genSaltSync(10);
    const finalPWD =  await bcrypt.hash(password, salt);
    return finalPWD;
};

helepers.comparePasswords = async (password, savePassword) => {
    try {
        return await bcrypt.compare(password, savePassword);
    } catch (error) {
        console.error(error);
    }
};

helepers.docedePasswords = async (password) => {
    try {
        return await bcrypt.decodeBase64(password)
    } catch (error) {
        console.log(error);
    }
};

module.exports = helepers;
const passport = require('passport');
const LocalStrategy = require('passport-local').Strategy;

const pool = require('../database');
const helpers = require('../lib/helpers');

passport.use('local.signin', new LocalStrategy({
    usernameField: 'login',
    passwordField: 'clave',
    passReqToCallback: true
}, async (req, login, clave, done) => {
    
    const result = await pool.query('SELECT * FROM empleados WHERE login = ?', [login]);
    
    //console.log(userName);
    console.log(result);
    if (result.length > 0) {
        const user = result[0]
        //console.log(user);
        const validPassword = await helpers.comparePasswords(clave, user.clave);
        if (validPassword) {
            const userName = await pool.query('SELECT * FROM personas WHERE dni = ?', [result[0].fk_dni]);
            done(null, user, req.flash('success',`Bienvenido ${userName[0].nombre} ${userName[0].apellido}`));
        } else {
            done(null, false, req.flash('message','Contraseña incorrecta'));
        }
    } else {
        return done(null, false, req.flash('message','El usuario no existe'));
    }

}));

passport.use('local.signup', new LocalStrategy({
    usernameField: 'login',
    passwordField: 'clave',
    passReqToCallback: true
}, async (req, login, clave, done) => {
    const { fk_idCategoria, fk_idestados, fk_dni } = req.body;
    const NEW_USER = {
        login,
        clave,
        fk_idCategoria,
        fk_idestados,
        fk_dni
    }

    NEW_USER.clave = await helpers.encryptPassword(clave)
    const result =  await pool.query('INSERT INTO empleados SET ?', [NEW_USER]);
    const userName = await pool.query('SELECT * FROM personas WHERE dni = ?', [NEW_USER.fk_dni]);

    NEW_USER.idEmpleado = result.insertId;
    //console.log(result);
    //Envio a la serializacion (de json a string)
    done(null, NEW_USER, req.flash('success',`Bienvenido ${userName[0].nombre} ${userName[0].apellido}`));
}));

passport.serializeUser((user, done) => {
    //Envio a la base de datos en la tabla sessions
    done(null , user);
});

passport.deserializeUser(async (user, done) => {
    //recuperacion de la session el base de datos
    const userName = await pool.query('SELECT * FROM personas WHERE dni = ?', [user.fk_dni]);
    const row = await pool.query('SELECT*FROM empleados WHERE idEmpleado = ?', [user.idEmpleado]);
    //console.log(user);
    row[0].name = `${userName[0].nombre} ${userName[0].apellido}`
    //console.log(row);
    //envio para la propieda local en forma global
    done(null , row[0]);
});
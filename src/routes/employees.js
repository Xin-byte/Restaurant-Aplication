const express = require('express');
const router = express.Router();
const pool = require('../database');
const helepers =  require('../lib/helpers');
const { isLoggedIn } = require('../lib/auth');
const { route } = require('./clients');
const upload = require('../lib/multer');

router.get('/employees', isLoggedIn, async (req, res) => {

    //consulta para personas
    const employees = await pool.query('SELECT*FROM v_empleado WHERE idEmpleado != ?', [req.user.idEmpleado]);
    const category = await pool.query('SELECT*FROM categorias');
    //console.log(category);
    res.render('links/employees', {employees, category, title: 'Empleados'});
})

router.post('/employeesRegister', upload.single('img'), async (req, res) => {
     
    const { clavec } = req.body;
    req.body.clavec = await helepers.encryptPassword(clavec);
    if (condition) {
        const { originalname } =  req.file
        req.body.img = originalname;
    } else {
        req.body.img = 'defaultp.png'
    }
    

    const registerEmployees = await pool.query('CALL p_nuevo_empleadoo(?)',[Object.values(req.body)]);
    const [[{...msg}]] = registerEmployees;
    req.flash('success', Object.values(msg));
    console.log(req.body);
    res.redirect('/employees');
});

router.get('/editEmployees/:id', isLoggedIn, async (req, res) => {
    const { id } = req.params
    const edit = await pool.query('SELECT*FROM v_empleado WHERE dni = ?', [id]);
    const category = await pool.query('SELECT*FROM categorias WHERE nomcategoria != ?',[edit[0].nomcategoria]);
    //console.log(category);
    res.render('links/editEmployees',{ edit: edit[0] , category,title:'Editar Empleado' });
});

router.post('/editEmployees', upload.single('img'), async (req, res) => {
    const defaultImg = await pool.query('SELECT * FROM v_empleado WHERE dni = ?',[req.body.dnic])
   
    if (req.file) {
        const { originalname } =  req.file;
        req.body.img = originalname;
    } else {
        req.body.img = defaultImg[0].foto;
    }
    
    const resultEdit = await pool.query('CALL p_actualizar_empleado(?)', [Object.values(req.body)])
    const [[{...msg}]] =  resultEdit;
    req.flash('success', Object.values(msg));
    res.redirect('/employees');
});

router.get('/deleteEmployees/:id', isLoggedIn, async (req, res) => {
    const { id } = req.params;
    //console.log(id);
    const resultDelete = await pool.query('CALL p_eliminar_empleado(?)', [id]);
    const [[{...msg}]] =  resultDelete;
    req.flash('success', Object.values(msg));
    res.redirect('/employees');
});

module.exports = router
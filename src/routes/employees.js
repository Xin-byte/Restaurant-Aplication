const express = require('express');
const router = express.Router();
const pool = require('../database');
const helepers =  require('../lib/helpers');
const { isLoggedIn } = require('../lib/auth');
const { route } = require('./clients');

router.get('/employees', isLoggedIn, async (req, res) => {

    //consulta para personas
    const employees = await pool.query('SELECT*FROM v_empleado WHERE idEmpleado != ?', [req.user.idEmpleado]);
    const category = await pool.query('SELECT*FROM categorias');
    //console.log(category);
    res.render('links/employees', {employees, category, title: 'Empleados'});
})

router.post('/employeesRegister', async (req, res) => {
     
    const { clavec } = req.body;
    req.body.clavec = await helepers.encryptPassword(clavec);
    const registerEmployees = await pool.query('CALL p_nuevo_empleado (?)',[Object.values(req.body)]);
    const [[{...msg}]] = registerEmployees;
    req.flash('success', Object.values(msg));
    //console.log(registerEmployees);
    res.redirect('/employees');
});

router.get('/editEmployees/:id', isLoggedIn, async (req, res) => {
    const { id } = req.params
    const edit = await pool.query('SELECT*FROM v_empleado WHERE dni = ?', [id]);
    const category = await pool.query('SELECT*FROM categorias WHERE nomcategoria != ?',[edit[0].nomcategoria]);
    //console.log(category);
    res.render('links/editEmployees',{ edit: edit[0] , category,title:'Editar Empleado' });
});

router.post('/editEmployees', isLoggedIn, async (req, res) => {
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
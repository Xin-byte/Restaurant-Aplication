const express =  require('express');
const router = express.Router();

const passport = require('passport');

const { isLoggedIn, isNotLoggedIn } = require('../lib/auth');

router.get('/signup', isNotLoggedIn, (req, res, next) => {
    res.render('auth/signup', { title: 'Registrarse' });
});

router.post('/signup', passport.authenticate('local.signup', {
    successRedirect: '/',
    failureRedirect: '/signup',
    failureFlash: true
}));

router.get('/signin', isNotLoggedIn, (req, res) => {
    res.render('auth/signin', { title: 'Ingresar' });
});

router.post('/signin', passport.authenticate('local.signin', {
    successRedirect: '/',
    failureRedirect: '/signin',
    failureFlash:true
}));

router.get('/logout', isLoggedIn,(req, res) => {
    //finalizar session
    req.logOut();
    //console.log(req.logout());
    res.redirect('/signin');
});

module.exports = router;
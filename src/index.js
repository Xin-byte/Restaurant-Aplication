//modulos               
const express = require('express');
const morgan = require('morgan');
const path = require('path');
const exphbs =  require('express-handlebars');
const flash = require('connect-flash');
const session = require('express-session');
const MySQLStore = require('express-mysql-session');
const passport = require('passport');
const multer =  require('multer');
const upload =  require('./lib/multer');

const { database } = require('./keys');
//Initialitation
const app = express();
require('./lib/passport');
//Settings
app.set('port', process.env.PORT || 4000);
app.set('views', path.join(__dirname, 'views'));
app.engine('hbs', exphbs({
    defaultLayout: 'main',
    layoutsDir: path.join(app.get('views'), 'layouts'),
    partialsDir: path.join(app.get('views'), 'partials'),
    extname: '.hbs',
    helpers: require('./lib/handlebars.js')

}));
app.set('view engine', 'hbs');

//Midlewares
app.use(session({
    secret: 'nodeSom',
    resave: false,
    saveUninitialized: false,
    store: new MySQLStore(database)
}));
app.use(flash());
app.use(morgan('dev'));
app.use(express.urlencoded({extended: false}));
app.use(express.json());
app.use(passport.initialize());
app.use(passport.session());
/*app.use(multer({
    dest: path.join(__dirname, 'public/uploads')
}).single('img'))*/

//Global Variables
app.use((req, res, next) => {
    app.locals.success = req.flash('success');
    app.locals.message = req.flash('message');
    app.locals.user = req.user;
    //console.log(app.locals);
    next();
});

//Routes
app.use(require('./routes'));
app.use(require('./routes/aunthentication'));
app.use(require('./routes/employees'));
app.use(require('./routes/clients'));
app.use(require('./routes/dish'));
app.use(require('./routes/reservation'));
app.use(require('./routes/reports'));
app.use('/reservation',require('./routes/addDish'))

//Publics
app.use(express.static(path.join(__dirname, 'public')));

//Start the server
app.listen(app.get('port'), () => {
    console.log(`Server running on port ${app.get('port')}`);
});

app.get('/*', (req, res) => {
    res.render('links/404', {title: 'Page not Found'});
});
const mysql = require('mysql');
const { database } = require('./keys');
const { promisify } = require('util');
//Conexion a la base de datos 
const pool = mysql.createPool(database);

pool.getConnection((err, connection) => {
    if (err) {
        if (err.code === 'PROTOCOL_CONNECTION_LOST') {
            console.error('Conexion a la base de datos cerrada');
        }
        if (err.code === 'ER_CON_COUNT_ERROR') {
            console.error('No fue posible conectarte a la base datos', database.database);
        }
        if (err.code === 'ECONNREFUSED') {
            console.error('Conexion Rechazada a la base de datos', database.database);
        }
    }
    if (connection) connection.release();
    console.log('Conectado a la base de datos', database.database);
    return;
});

//de callback a promisify
pool.query = promisify(pool.query);

module.exports = pool;
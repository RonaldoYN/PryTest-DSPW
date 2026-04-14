// -- Readme --//

Repository Curso Desarrollo Web Integrado 

Temas, Archivos, Modelos, Paginas, Etc

// Sesion 2 - Instalacion de Jakarta EE = TomcCat 10 Contenedor
//Sesion 3 - Creacion de Web HTML Estatica


<%-- 
    Document   : Index
    Created on : 13 abr. 2026, 19:09:08
    Author     : LAB-USR-LCENTRO by: ¬RNV¬
--%>

<%@page import="Operaciones.Aritmetica"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>JSP Page</title>
    </head>
    <body>
        <h1> Expresiones Lenguaje (EL)</h1>
        <%= new java.util.Date().toString() %><br>
        
        <%= "Desarrollo Web Integrado".toUpperCase() %><br>
        
        <%= (100-50)/(float)5 %>
        
        <h2> Ejemplo de Scriplet </h2>
        <%  int num = 7, fac = 1;
            for(int i=num; i>1; i--) {
            fac *= i;
            }
        %>
        <h3>  Valor de Facotiral => <%= fac %> </h3>
        
    <%-- 
       Expresiones: <&= &> ----> PARA MOSTRAR DATOS JAVA
                    <% %> -----> PARA ESTABLECER O DETERMINAR ESTILOS
                    <%-- --%> <%--Son Comentarios para NIVEL CLIENTE
                    Prefireble Hacer un Package con un .java para realizar lo "complejo"
                    e instanciar en el index.jsp
    --%>
        
    <h4> Directiva @page import </h4>
    <h5> La suma de 5 y 10 es: <%= Aritmetica.sumar(5,10) %></h5>
        
    <!-- Modo Print -->

    <h6> Intento </h6>
    <% String nom = "Oscar" %>
    <% String ape = "Barnett" %>
    <br>
    <h1>El correo de <%= nom.toString() %> es <%= nom.toString(),.ape.toString().@gmail.com %> </h1> 
    
    
    </body>
</html>

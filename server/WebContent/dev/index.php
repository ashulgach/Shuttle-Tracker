<?php

//RouteCoordDistances::loadDistanceTable();
//RouteCoordDistances::calcDistances();

//var_dump($etas);
include("header.php");
include_once("application.php");
include_once("apps/data_service.php");  
include_once("apps/routecoorddistances.php");

?>
 

<!--<div id="boxes">
 
 
    <div id="dialog" class="window">
        Are you still here?
        <br /> 
        <!-- close button is defined as close class 
        <a href="#" class="close">I'm here!</a>    
        
 
    </div>
 
    <div id="mask"></div>
</div> -->


<div data-role="page" id="eta">
    <div  data-role="header" class="ui-bar" data-inline="true"> 
        <h1>RPI Shuttle Tracking</h1> 
            
    </div>
<div data-role="content">
<?
   DataService::displayETAs();
   DataServiceData::recordStats("Get Next ETA"); 
?>
</div>
<? 
include("footer.php"); 
?>

</body>
</html>
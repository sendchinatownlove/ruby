# frozen_string_literal: true

def stats_html(_box1, _box2, _box3, _box4, _box5, _box6)
  <<~HTML.chomp
        <div>
            <style>
                .container {
                    display: flex; 
                    flex-direction: row;
                    flex-wrap: wrap; 
                    justify-content: center; 
                    font-family: 'Open Sans', sans-serif; 
                    color: white; 
                    font-weight:bold; 
                    background-color: #A9262E; 
                    height: 100%; 
                    width: 100%;
                }
    
                .stats-box {
                    display: flex; 
                    flex-direction: column; 
                    align-items: center; 
                    width: 30%; 
                    margin: 30px 0px;
                    text-align: center;
                }
    
                .stats-text {
                    font-size: 50px; 
                    margin: 15px 0px;
                }
    
                .stats-description-text {
                    font-size: 16px;
                }
    
                @media only screen and (max-width: 680px) {
                    .container {
                        flex-direction: column;
                        align-items: center;
                    }
    
                    .stats-box {
                        width: 100%; 
                        margin: 20px 0px;
                    }
                }
            </style>
            <div class="container"> 
                <div class="stats-box">
                    <div style="font-size: 50px; margin: 15px 0px;" id="statsbox1">$516,051</div>
                    <div style="font-size: 16px;">Raised</div>
                </div>
    
                <div class="stats-box">
                    <div class="stats-text" id="statsbox2">13,818</div>
                    <div class="stats-description-text">Meals donated</div>
                </div>
    
                <div class="stats-box">
                    <div class="stats-text" id="statsbox3">$36,573</div>
                    <div class="stats-description-text">Raised from 2 Food Crawls</div>
                </div>
    
                <div class="stats-box">
                    <div class="stats-text" id="statsbox4">20,102</div>
                    <div class="stats-description-text">Donations and vouchers purchased</div>
                </div>
    
                <div class="stats-box">
                    <div class="stats-text" id="statsbox5">28</div>
                    <div class="stats-description-text">Merchants directly supported</div>
                </div>
    
                <div class="stats-box">
                    <div class="stats-text" id="statsbox6">$47,689</div>
                    <div class="stats-description-text">Raised for Light Up Chinatown</div>
                </div>
            </div>
        </div>
    <script>
    function quotation(id, text) {
        var q = document.getElementById(id);
        if (q) q.innerHTML = text;
        // var q = $('#'+id);
        // if (q) q.html().replace("", text);
    }
    
    fetch("https://sendchinatownlove.herokuapp.com/stats")
        .then(response => response.json())
        .then(data => {
            Object.keys(data).forEach(function(key) {
            quotation(`stats${key}`, data[key])
    })
    
    });
    
    </script>
  HTML
end

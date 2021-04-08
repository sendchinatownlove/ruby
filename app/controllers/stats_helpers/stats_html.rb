def stats_html(box1, box2, box3, box4, box5, box6)

    return <<-HTML.chomp
    <div style="display: flex; flex-wrap: wrap; justify-content: center; font-family: 'Open Sans', sans-serif; color: white; font-weight:bold;">
    <div style="display: flex; flex-direction: column; align-items: center; width: 30%; margin: 30px 0px;">
        <div style="font-size: 50px; margin: 15px 0px;" id="statsbox1">$516,051</div>
        <div style="font-size: 16px;">Raised</div>
    </div>

    <div style="display: flex; flex-direction: column; align-items: center; width: 30%; margin: 30px 0px;">
        <div style="font-size: 50px; margin: 15px 0px;" id="statsbox2">13,818</div>
        <div style="font-size: 16px;">Meals donated</div>
    </div>

    <div style="display: flex; flex-direction: column; align-items: center; width: 30%; margin: 30px 0px;">
        <div style="font-size: 50px; margin: 15px 0px;" id="statsbox3">36,573</div>
        <div style="font-size: 16px;">Raised from 2 Food Crawls</div>
    </div>

    <div style="display: flex; flex-direction: column; align-items: center; width: 30%; margin: 30px 0px;">
        <div style="font-size: 50px; margin: 15px 0px;" id="statsbox4">53,737</div>
        <div style="font-size: 16px;">Donations and vouchers purchased</div>
    </div>

    <div style="display: flex; flex-direction: column; align-items: center; width: 30%; margin: 30px 0px;">
        <div style="font-size: 50px; margin: 15px 0px;" id="statsbox5">30</div>
        <div style="font-size: 16px;">Merchants directly supported</div>
    </div>

    <div style="display: flex; flex-direction: column; align-items: center; width: 30%; margin: 30px 0px;">
        <div style="font-size: 50px; margin: 15px 0px;" id="statsbox6">$47,689</div>
        <div style="font-size: 16px;">Raised for Light Up Chinatown</div>
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
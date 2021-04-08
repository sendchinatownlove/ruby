def stats_html(box1, box2, box3, box4, box5, box6)

    return <<-HTML.chomp
    <div style="display: flex; flex-wrap: wrap; justify-content: center; font-family: 'Open Sans', sans-serif; color: white; font-weight:bold;">
    <div style="display: flex; flex-direction: column; align-items: center; width: 30%; margin: 30px 0px;">
        <div style="font-size: 50px; margin: 15px 0px;">${box1}</div>
        <div style="font-size: 16px;">Raised</div>
    </div>

    <div style="display: flex; flex-direction: column; align-items: center; width: 30%; margin: 30px 0px;">
        <div style="font-size: 50px; margin: 15px 0px;">${box2}</div>
        <div style="font-size: 16px;">Meals donated</div>
    </div>

    <div style="display: flex; flex-direction: column; align-items: center; width: 30%; margin: 30px 0px;">
        <div style="font-size: 50px; margin: 15px 0px;">${box3}</div>
        <div style="font-size: 16px;">Raised from 2 Food Crawls</div>
    </div>

    <div style="display: flex; flex-direction: column; align-items: center; width: 30%; margin: 30px 0px;">
        <div style="font-size: 50px; margin: 15px 0px;">${box4}</div>
        <div style="font-size: 16px;">Donations and vouchers purchased</div>
    </div>

    <div style="display: flex; flex-direction: column; align-items: center; width: 30%; margin: 30px 0px;">
        <div style="font-size: 50px; margin: 15px 0px;">${box5}</div>
        <div style="font-size: 16px;">Merchants directly supported</div>
    </div>

    <div style="display: flex; flex-direction: column; align-items: center; width: 30%; margin: 30px 0px;">
        <div style="font-size: 50px; margin: 15px 0px;">${box6}</div>
        <div style="font-size: 16px;">Raised for Light Up Chinatown</div>
    </div>
</div>
            HTML
end 
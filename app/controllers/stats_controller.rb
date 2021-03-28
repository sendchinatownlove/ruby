class StatsController < ApplicationController
    def donation_totals
        
        @result = ActiveRecord::Base.connection.execute(donation_query())
        # result.each do |row|
        #     puts row
        # end
        # render json: @result
        return @result
      end
    def index
        # some other stuff going on...
        # donation_totals()
        show2(donation_totals()) 
    end
    
#   def show
#      render json: {}
#   end

  def donation_query
    query = <<-SQL 

    -- All donations and giftcards purchased 
    -- User level transactions
    with giftcards as (
        select 
            d.id 
            ,d.gift_card_id
            ,d.receipt_id
            ,d.expiration at time zone 'utc' at time zone 'America/New_York'
            ,d.created_at at time zone 'utc' at time zone 'America/New_York'
            ,d.updated_at at time zone 'utc' at time zone 'America/New_York'
            ,d.item_id
            ,d.seller_gift_card_id 
            ,d.single_use
            ,a.value as giftcard_amount
            ,a.gift_card_detail_id 
        from gift_card_details as d
        join gift_card_amounts as a 
        on d.id = a.gift_card_detail_id
        
        ), 
        all_donations as (
        select 
        c.email
        ,i.purchaser_id
        ,s.seller_id as merchant
        ,i.payment_intent_id
        ,g.single_use as gam
        ,(case when i.item_type = 1 then 'giftcard' else 'donation' end) as purchase_type
        ,coalesce (d.item_id, g.item_id) as transaction_id
        ,coalesce(d.amount/100, g.giftcard_amount/100) as dollar_amount
        ,date(i.created_at at time zone 'utc' at time zone 'America/New_York') as created
        ,date(i.updated_at at time zone 'utc' at time zone 'America/New_York') as last_update
        ,i.created_at at time zone 'utc' at time zone 'America/New_York' as created_timepstamp
        ,i.refunded
        from items as i 
        left join donation_details as d
        on i.id = d.item_id
        left join giftcards as g      
        on i.id = g.item_id
        left join sellers as s 
        on i.seller_id = s.id
        left join contacts as c   
        on i.purchaser_id = c.id
        left join payment_intents as p
        on i.payment_intent_id = p.id 
        where refunded = 'false'
        order by created_timepstamp desc
        ), 
        pool as (
        select 
            payment_intent_id
            ,refunded
            ,date(p.created_at at time zone 'utc' at time zone 'America/New_York') as created
            ,count(*) as num
        from donation_details as d
        join items as i
        on d.item_id = i.id
        join payment_intents as p
        on i.payment_intent_id = p.id 
        group by 1,2,3
        )
    
    -- -- RUN TO GET BI-WEEKLY PAYOUT $
        SELECT  
        -- merchant
        min(created) as start_date
        ,max(created) as end_date 
        ,sum(case when purchase_type = 'donation' then dollar_amount else 0 end) as donation
        ,sum(case when purchase_type = 'giftcard' AND gam is FALSE then dollar_amount else 0 end) as giftcard
        ,sum(case when purchase_type = 'giftcard' AND gam is TRUE then dollar_amount else 0 end) as GAM
        /*if purchase type is giftcard, and gam is TRUE then giftcard dollar amount? = GAM */ 
        ,sum(dollar_amount) as total
    
        from all_donations
        /*** Input Dates Here ***/ 
        -- where created >= '2020-03-16' and created < '2021-03-23'
        -- group by 
        -- merchant
        /*order by 1 */
  values
  
          SQL
        end 
        def show2(donation_totals)
            puts (donation_totals.values())
            box1 = donation_totals.values()[4] #"$10,000"
            box2 = "7,489"
            box3 = "$36000"
            box4 = "20,102"
            box5 = "27"
            box6 = "29"
            render html:  <<-HERDOC
            <div class="" data-sr-id="3"
            style="; visibility: visible;  -webkit-transform: translateY(0) scale(1); opacity: 1;transform: translateY(0) scale(1); opacity: 1;-webkit-transition: -webkit-transform 0.3s ease-in 0.3s, opacity 0.3s ease-in 0.3s; transition: transform 0.3s ease-in 0.3s, opacity 0.3s ease-in 0.3s; ">
            <div class="wsite-multicol">
                <div class="wsite-multicol-table-wrap" style="margin:0 -0px;">
                    <table class="wsite-multicol-table" style="border-collapse: collapse">
                        <tbody class="wsite-multicol-tbody">
                            <tr class="wsite-multicol-tr">
                                <td class="wsite-multicol-col" style="width:33.333333333333%; padding:0 0px;">
        
        
        
                                    <div id="275099670747963262">
                                        <div>
                                            <style type="text/css">
                                                #element-70abd3a2-c519-4913-bddb-19403c2359ea .border-box {
                                                    -moz-box-sizing: border-box;
                                                    -webkit-box-sizing: border-box;
                                                    -ms-box-sizing: border-box;
                                                    box-sizing: border-box;
                                                }
        
                                                #element-70abd3a2-c519-4913-bddb-19403c2359ea .hide-box {
                                                    -moz-box-sizing: border-box;
                                                    -webkit-box-sizing: border-box;
                                                    -ms-box-sizing: border-box;
                                                    box-sizing: border-box;
                                                }
        
                                                #element-70abd3a2-c519-4913-bddb-19403c2359ea .hide-box .hide-box-content {
                                                    -moz-box-sizing: border-box;
                                                    -webkit-box-sizing: border-box;
                                                    -ms-box-sizing: border-box;
                                                    box-sizing: border-box;
                                                }
                                            </style>
                                            <div id="element-70abd3a2-c519-4913-bddb-19403c2359ea"
                                                data-platform-element-id="874959678356211109-1.0.1"
                                                class="platform-element-contents">
                                                <div class="hide-box" style="display: none;">
                                                    <div class="hide-box-content">
                                                        <div style="width: auto">
                                                            <div></div>
                                                            <div id="978991971105406468">
                                                                <div>
                                                                    <style type="text/css">
                                                                        #element-de42ff17-5a35-4521-9da5-c0129df2b712 .content-color-box-wrapper {
                                                                            padding: 0px;
                                                                            border-radius: 0px;
                                                                            background-color: rgba(255, 255, 255, 0.2);
                                                                            border-style: None;
                                                                            border-color: #555555;
                                                                            border-width: 3px;
                                                                        }
                                                                    </style>
                                                                    <div id="element-de42ff17-5a35-4521-9da5-c0129df2b712"
                                                                        data-platform-element-id="698263678581730663-1.1.0"
                                                                        class="platform-element-contents">
                                                                        <div class="content-color-box-wrapper">
                                                                            <div style="width: 100%">
                                                                                <div></div>
                                                                                <div class="wsite-spacer" style="height:22px;">
                                                                                </div>
        
                                                                                <div class="paragraph"
                                                                                    style="text-align:center;"><strong>
                                                                                        <font color="#ffffff">​</font>
                                                                                    </strong></div>
        
                                                                                <h2 class="wsite-content-title"
                                                                                    style="text-align:center;"><span>
                                                                                        <font color="#ffffff" size="7">$</font>
                                                                                        <font size="7" color="#ffffff">250,198
                                                                                        </font>
                                                                                    </span></h2>
        
                                                                                <div class="paragraph"
                                                                                    style="text-align:center;"><strong>
                                                                                        <font color="#ffffff">Raised<br>​</font>
                                                                                    </strong></div>
                                                                            </div>
                                                                        </div>
                                                                    </div>
                                                                    <div style="clear:both;"></div>
                                                                </div>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </div>
        
                                            </div>
                                            <div style="clear:both;"></div>
                                        </div>
                                    </div>
        
                                    <div id="658623798973152265">
                                        <div>
                                            <style type="text/css">
                                                #element-5e33e1e9-304c-4a60-9424-d7081180d2a2 .content-color-box-wrapper {
                                                    padding: 0px;
                                                    border-radius: 0px;
                                                    background-color: #8d2424;
                                                    border-style: None;
                                                    border-color: #555555;
                                                    border-width: 3px;
                                                }
                                            </style>
                                            <div id="element-5e33e1e9-304c-4a60-9424-d7081180d2a2"
                                                data-platform-element-id="698263678581730663-1.1.0"
                                                class="platform-element-contents">
                                                <div class="content-color-box-wrapper">
                                                    <div style="width: 100%">
                                                        <div></div>
                                                        <div class="wsite-spacer" style="height:37px;"></div>
        
                                                        <h2 class="wsite-content-title" style="text-align:center;"><span>
                                                                <font color="#ffffff" size="7">#{box1}</font>
                                                            </span></h2>
        
                                                        <div class="paragraph" style="text-align:center;"><strong>
                                                                <font color="#ffffff">Raised<br>​</font>
                                                            </strong></div>
                                                    </div>
                                                </div>
                                            </div>
                                            <div style="clear:both;"></div>
                                        </div>
                                    </div>
        
                                    <div id="223149305282148644">
                                        <div>
                                            <style type="text/css">
                                                #element-2cd44c4e-42f4-42cd-ae63-d363bbbcbd9b .content-color-box-wrapper {
                                                    padding: 0px;
                                                    border-radius: 0px;
                                                    background-color: #8d2424;
                                                    border-style: None;
                                                    border-color: #555555;
                                                    border-width: 3px;
                                                }
                                            </style>
                                            <div id="element-2cd44c4e-42f4-42cd-ae63-d363bbbcbd9b"
                                                data-platform-element-id="698263678581730663-1.1.0"
                                                class="platform-element-contents">
                                                <div class="content-color-box-wrapper">
                                                    <div style="width: 100%">
                                                        <div></div>
                                                        <div class="wsite-spacer" style="height:37px;"></div>
        
                                                        <h2 class="wsite-content-title" style="text-align:center;">
                                                            <font color="#ffffff" size="7">#{box4}</font>
                                                        </h2>
        
                                                        <div class="paragraph" style="text-align:center;"><strong>
                                                                <font color="#ffffff">Donations and vouchers purchased<br>​
                                                                </font>
                                                            </strong></div>
                                                    </div>
                                                </div>
                                            </div>
                                            <div style="clear:both;"></div>
                                        </div>
                                    </div>
        
        
        
                                </td>
                                <td class="wsite-multicol-col" style="width:33.916763905095%; padding:0 0px;">
        
        
        
                                    <div id="658623798973152265">
                                        <div>
                                            <style type="text/css">
                                                #element-5e33e1e9-304c-4a60-9424-d7081180d2a2 .content-color-box-wrapper {
                                                    padding: 0px;
                                                    border-radius: 0px;
                                                    background-color: #8d2424;
                                                    border-style: None;
                                                    border-color: #555555;
                                                    border-width: 3px;
                                                }
                                            </style>
                                            <div id="element-5e33e1e9-304c-4a60-9424-d7081180d2a2"
                                                data-platform-element-id="698263678581730663-1.1.0"
                                                class="platform-element-contents">
                                                <div class="content-color-box-wrapper">
                                                    <div style="width: 100%">
                                                        <div></div>
                                                        <div class="wsite-spacer" style="height:37px;"></div>
        
                                                        <h2 class="wsite-content-title" style="text-align:center;"><span>
                                                                <font color="#ffffff" size="7">#{box2}</font>
                                                            </span></h2>
        
                                                        <div class="paragraph" style="text-align:center;"><strong>
                                                                <font color="#ffffff">Meals donated<br>​</font>
                                                            </strong></div>
                                                    </div>
                                                </div>
                                            </div>
                                            <div style="clear:both;"></div>
                                        </div>
                                    </div>
        
                                    <div id="284877734963953236">
                                        <div>
                                            <style type="text/css">
                                                #element-e33921c8-d2ad-4ce7-a762-f5c770d47564 .content-color-box-wrapper {
                                                    padding: 0px;
                                                    border-radius: 0px;
                                                    background-color: #8d2424;
                                                    border-style: None;
                                                    border-color: #555555;
                                                    border-width: 3px;
                                                }
                                            </style>
                                            <div id="element-e33921c8-d2ad-4ce7-a762-f5c770d47564"
                                                data-platform-element-id="698263678581730663-1.1.0"
                                                class="platform-element-contents">
                                                <div class="content-color-box-wrapper">
                                                    <div style="width: 100%">
                                                        <div></div>
                                                        <div class="wsite-spacer" style="height:37px;"></div>
        
                                                        <h2 class="wsite-content-title" style="text-align:center;">
                                                            <font color="#ffffff" size="7">#{box5}</font>
                                                        </h2>
        
                                                        <div class="paragraph" style="text-align:center;"><strong>
                                                                <font color="#ffffff">Merchants directly supported<br>​</font>
                                                            </strong></div>
                                                    </div>
                                                </div>
                                            </div>
                                            <div style="clear:both;"></div>
                                        </div>
                                    </div>
        
        
        
                                </td>
                                <td class="wsite-multicol-col" style="width:32.749902761571%; padding:0 0px;">
        
        
        
                                    <div id="872091167963846309">
                                        <div>
                                            <style type="text/css">
                                                #element-93965d30-63e3-4a15-a888-395b43f1f556 .content-color-box-wrapper {
                                                    padding: 0px;
                                                    border-radius: 0px;
                                                    background-color: #8d2424;
                                                    border-style: None;
                                                    border-color: #555555;
                                                    border-width: 3px;
                                                }
                                            </style>
                                            <div id="element-93965d30-63e3-4a15-a888-395b43f1f556"
                                                data-platform-element-id="698263678581730663-1.1.0"
                                                class="platform-element-contents">
                                                <div class="content-color-box-wrapper">
                                                    <div style="width: 100%">
                                                        <div></div>
                                                        <div class="wsite-spacer" style="height:37px;"></div>
        
                                                        <h2 class="wsite-content-title" style="text-align:center;"><span>
                                                                <font color="#ffffff" size="7">$</font>
                                                            </span>
                                                            <font color="#ffffff" size="7">#{box3}</font><span></span>
                                                        </h2>
        
                                                        <div class="paragraph" style="text-align:center;"><strong>
                                                                <font color="#ffffff">Raised from 2 Food Crawls<br>​</font>
                                                            </strong></div>
                                                    </div>
                                                </div>
                                            </div>
                                            <div style="clear:both;"></div>
                                        </div>
                                    </div>
        
                                    <div id="554966160745381682">
                                        <div>
                                            <style type="text/css">
                                                #element-50055529-cb18-4e52-beeb-8f4ef9bd8cec .content-color-box-wrapper {
                                                    padding: 0px;
                                                    border-radius: 0px;
                                                    background-color: #8d2424;
                                                    border-style: None;
                                                    border-color: #555555;
                                                    border-width: 3px;
                                                }
                                            </style>
                                            <div id="element-50055529-cb18-4e52-beeb-8f4ef9bd8cec"
                                                data-platform-element-id="698263678581730663-1.1.0"
                                                class="platform-element-contents">
                                                <div class="content-color-box-wrapper">
                                                    <div style="width: 100%">
                                                        <div></div>
                                                        <div class="wsite-spacer" style="height:37px;"></div>
        
                                                        <h2 class="wsite-content-title" style="text-align:center;">
                                                            <font color="#ffffff" size="7">#{box6}</font>
                                                        </h2>
        
                                                        <div class="paragraph" style="text-align:center;"><strong>
                                                                <font color="#ffffff">Raised for Light Up Chinatown<br>​</font>
                                                            </strong></div>
                                                    </div>
                                                </div>
                                            </div>
                                            <div style="clear:both;"></div>
                                            <script type="text/javascript" class="element-script">function setupElement554966160745381682() {
                                                    var requireFunc = window.platformElementRequire || window.require;
        
                                                    // Relies on a global require, specific to platform elements
                                                    requireFunc([
                                                        'w-global',
                                                        'underscore',
                                                        'jquery',
                                                        'backbone',
                                                        'util/platform/elements/PlatformElement',
                                                        'util/platform/elements/PlatformElementSettings'
                                                    ], function (
                                                        _W,
                                                        _,
                                                        $,
                                                        Backbone,
                                                        PlatformElement,
                                                        PlatformElementSettings
                                                    ) {
                                                        var dependencies = null || [];
                                                        var platform_element_id = "698263678581730663-1.1.0";
        
                                                        if (typeof _W.loadedPlatformDependencies === 'undefined') {
                                                            _W.loadedPlatformDependencies = [];
                                                        }
        
                                                        if (typeof _W.platformElements === 'undefined') {
                                                            _W.platformElements = [];
                                                        }
        
                                                        if (typeof _W.platformElements[platform_element_id] === 'undefined') {
                                                            _W.platformElements[platform_element_id] = {};
                                                            _W.platformElements[platform_element_id].deferredObject = new $.Deferred();
                                                            _W.platformElements[platform_element_id].deferredPromise = _W.platformElements[platform_element_id].deferredObject.promise();
                                                        }
        
                                                        if (_.intersection(_W.loadedPlatformDependencies, dependencies).length !== dependencies.length) {
                                                            _.reduce(dependencies, function (promise, nextScript) {
                                                                _W.loadedPlatformDependencies.push(nextScript);
                                                                return promise.then(function () {
                                                                    return $.getScript(nextScript);
                                                                });
                                                            }, $().promise()).then(function () {
                                                                _W.platformElements[platform_element_id].deferredObject.resolve();
                                                            });
                                                        }
        
                                                        if (dependencies.length === 0) {
                                                            _W.platformElements[platform_element_id].deferredObject.resolve();
                                                        }
        
                                                        _W.platformElements[platform_element_id].deferredPromise.done(function () {
                                                            var _ElementDefinition = PlatformElement.extend({ initialize: function (options) { }, events: {} });;
        
                                                            if (typeof _ElementDefinition == 'undefined' || typeof _ElementDefinition == 'null') {
                                                                var _ElementDefinition = PlatformElement.extend({});
                                                            }
        
                                                            var _Element = _ElementDefinition.extend({
                                                                initialize: function () {
                                                                    // we still want to call the initialize function defined by the developer
                                                                    // however, we don't want to call it until placeholders have been replaced
                                                                    this.placeholderInterval = setInterval(function () {
                                                                        // so use setInterval to check for placeholders.
                                                                        if (this.$('.platform-element-child-placeholder').length == 0) {
                                                                            clearInterval(this.placeholderInterval);
                                                                            this.constructor.__super__.initialize.apply(this);
                                                                        }
                                                                    }.bind(this), 100);
                                                                }
                                                            });
        
                                                            _Element.prototype.settings = new PlatformElementSettings({ "borderWidth_each": [{ "borderWidth_index": 0 }, { "borderWidth_index": 1 }, { "borderWidth_index": 2 }], "backgroundColor": "#8d2424", "backgroundTransparency": 100, "spacingSize": 0, "cornerRadius": 0, "borderStyle": "None", "borderColor": "#555", "borderWidth": 3, "borderTransparency": 100 });
                                                            _Element.prototype.settings.page_element_id = "554966160745381682";
        
                                                            _Element.prototype.element_id = "50055529-cb18-4e52-beeb-8f4ef9bd8cec";
                                                            _Element.prototype.user_id = "131935948";
                                                            _Element.prototype.site_id = "885213738189024979";
                                                            _Element.prototype.assets_path = "//marketplace.editmysite.com/uploads/b/marketplace-elements-698263678581730663-1.1.0/assets/";
                                                            new _Element({
                                                                el: '#element-50055529-cb18-4e52-beeb-8f4ef9bd8cec'
                                                            });
                                                        });
                                                    });
        
                                                }
        
                                                if (typeof document.documentElement.appReady == 'undefined') {
                                                    document.documentElement.appReady = 0;
                                                }
        
                                                if (document.documentElement.appReady || (window.inEditor && window.inEditor())) {
                                                    setupElement554966160745381682();
                                                } else if (document.createEvent && document.addEventListener) {
                                                    document.addEventListener('appReady', setupElement554966160745381682, false);
                                                } else {
                                                    document.documentElement.attachEvent('onpropertychange', function (event) {
                                                        if (event.propertyName == 'appReady') {
                                                            setupElement554966160745381682();
                                                        }
                                                    });
                                                }
                                                function quotation(id, text) {
                                                    var q = document.getElementById(id);
                                                    if (q) q.innerHTML = text;
                                                    // var q = $('#'+id);
                                                    // if (q) q.html().replace("", text);
                                                }
        
                                                fetch("https://ifconfig.me/all.json")
                                                    .then(response => response.json())
                                                    .then(data => quotation('statsbox1', data["ip_addr"]));
                                                quotation('statsbox1', '200');
                                                console.log($('#statsbox1'))
                                            </script>
                                        </div>
                                    </div>
        
        
        
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
            HERDOC
              .html_safe# render :text => @model_object.html_content
          end
        
          def item_gift_card_detail_json
            @message = <<-HERDOC
            <div class="sc-kfYqjs fWaWOh"><div class="sc-fKgIGh bGktlx"><div class="sc-bCwgka gWffEH">Metric1</div><br><div class="sc-iwaifL ctfufu">Raised</div><br><br><div class="sc-bCwgka gWffEH">Metric2</div><br><div class="sc-iwaifL ctfufu">Donations and vouchers purchased</div></div><div class="sc-fKgIGh bGktlx"><div class="sc-bCwgka gWffEH">Metric2</div><br><div class="sc-iwaifL ctfufu">Meals Donated</div><br><br><div class="sc-bCwgka gWffEH">Metric2</div><br><div class="sc-iwaifL ctfufu">Merchants directly supported</div></div><div class="sc-fKgIGh bGktlx"><div class="sc-bCwgka gWffEH">Metric3</div><br><div class="sc-iwaifL ctfufu">Raised from 2020 Food Crawl</div><br><br><div class="sc-bCwgka gWffEH">Metric2</div><br><div class="sc-iwaifL ctfufu">Raised for Light Up Chinatown</div></div></div>
            HERDOC
          end
end

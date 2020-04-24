<!--https://mjml.io/try-it-live/HyrF2vgFU-->
<mjml>
  <mj-body background-color="#ccd3e0">
    <mj-section background-color="#fff" padding-bottom="20px" padding-top="20px">
      <mj-column width="100%">
        <!--<mj-image src="http://go.mailjet.com/tplimg/mtrq/b/ox8s/mg1qi.png" alt="" align="center" border="none" width="100px" padding-left="0px" padding-right="0px" padding-bottom="10px" padding-top="10px"></mj-image>
        <mj-image src="http://go.mailjet.com/tplimg/mtrq/b/ox8s/mg1qz.png" alt="" align="center" border="none" width="200px" padding-left="0px" padding-right="0px" padding-bottom="0px" padding-top="0"></mj-image>-->
      </mj-column>
    </mj-section>
    <mj-section background-color="#fff" padding-bottom="0px" padding-top="0">
      <mj-column width="100%">
        <mj-text align="center" font-size="13px" color="#000" font-family="Ubuntu, Helvetica, Arial, sans-serif" padding-left="25px" padding-right="25px" padding-bottom="0" padding-top="28px">Hello
          <p style="font-size:16px; color:#000"><strong>
            [[FirstName]]
            </strong></p>
        </mj-text>
      </mj-column>
      <mj-column width="100%">
        <mj-text align="center" color="#000" font-size="13px" font-family="Helvetica" padding="10px"><span style="font-size:20px; font-weight:bold">Thank you for supporting</span>
          <br/>

          <mj-column width="100%">
            <mj-text align="center" font-size="13px" color="#000" font-family="Ubuntu, Helvetica, Arial, sans-serif" padding-left="25px" padding-right="25px" padding-bottom="18px" padding-top="28px">
              <span style="font-size:24px; font-weight:bold; ;">Shunfa bakery</span>
            </mj-text>
          </mj-column>


          <br/><br/><br/>
          <span style="font-size:15px">Please find your receipt below.</span></mj-text>
        <mj-divider border-color="#000" border-width="2px" border-style="solid" padding-left="20px" padding-right="20px" padding-bottom="0px" padding-top="0"></mj-divider>
      </mj-column>
      <!-- Start Section-->

      <mj-column>
        <mj-text align="center" color="#000" font-size="15px" font-family="Ubuntu, Helvetica, Arial, sans-serif" padding-left="25px" padding-right="25px" padding-bottom="0px"><strong>Giftcard Number</strong></mj-text>
        <mj-text align="center" color="#000" font-size="13px" font-family="Helvetica" padding-left="25px" padding-right="25px" padding-bottom="20px" padding-top="10px">[[OrderNumber]]</mj-text>

      </mj-column>
      <!--End Section-->
    </mj-section>

    <mj-section background-color="#fff" padding-bottom="15px">
      <mj-column>
        <mj-text align="center" color="#000" font-size="15px" font-family="Ubuntu, Helvetica, Arial, sans-serif" padding-left="25px" padding-right="25px" padding-bottom="0px"><strong>Order Date</strong></mj-text>
        <mj-text align="center" color="#000" font-size="13px" font-family="Helvetica" padding-left="25px" padding-right="25px" padding-bottom="20px" padding-top="10px">[[OrderDate]]</mj-text>
      </mj-column>
      <mj-column>
        <mj-text align="center" color="#000" font-size="15px" font-family="Ubuntu, Helvetica, Arial, sans-serif" padding-left="25px" padding-right="25px" padding-bottom="0px"><strong>Total</strong></mj-text>
        <mj-text align="center" color="#000" font-size="13px" font-family="Helvetica" padding-left="25px" padding-right="25px" padding-bottom="20px" padding-top="10px">[[TotalPrice]]</mj-text>
      </mj-column>
    </mj-section>
    <mj-section background-color="#fff" padding-bottom="20px" padding-top="20px">
      <mj-column width="100%">
        <mj-divider border-color="#000" border-width="2px" border-style="solid" padding-left="20px" padding-right="20px" padding-bottom="0px" padding-top="0"></mj-divider>

        <mj-button background-color="#000" color="#fff" font-size="14px" align="center" font-weight="bold" border="none" padding="15px 30px" border-radius="10px" href="https://mjml.io" font-family="Helvetica" padding-left="25px" padding-right="25px" padding-bottom="10px">View Receipt</mj-button>
      </mj-column>
    </mj-section>
    <mj-section background-color="#fff" padding-bottom="5px" padding-top="0">
      <mj-column width="100%">
        <mj-divider border-color="#fff" border-width="2px" border-style="solid" padding-left="20px" padding-right="20px" padding-bottom="0px" padding-top="0"></mj-divider>
        <mj-text align="center" color="#000" font-size="15px" font-family="Helvetica" padding-left="25px" padding-right="25px" padding-bottom="20px" padding-top="20px">Best,
          <br/>
          <span style="font-size:15px">The [[CompanyName]] Team</span></mj-text>
      </mj-column>
    </mj-section>
  </mj-body>
</mjml>
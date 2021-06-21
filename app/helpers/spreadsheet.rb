require 'google_drive'

# Creates a session. This will prompt the credential via command line for the
# first time and save it to config.json file for later usages.
# See this document to learn how to create config.json:
# https://github.com/gimite/google-drive-ruby/blob/master/doc/authorization.md

# file = File.read('./sa.json')

# session = GoogleDrive::Session.from_service_account_key(parsed_json)
# First worksheet of
# https://docs.google.com/spreadsheet/ccc?key=pz7XtlQC-PYx-jrVMJErTcg
# Or https://docs.google.com/a/someone.com/spreadsheets/d/pz7XtlQC-PYx-jrVMJErTcg/edit?usp=drive_web
# ws = session.file_by_id("1RFbedwlWR2I0d0ELllCeha9QCdZK_PQyJt_RcaerexU").worksheets[0]

module LiveStats
  def self.pull
    $google_config = ENV['GOOGLEDRIVE_SECRET']
    session = GoogleDrive::Session.from_service_account_key(StringIO.new($google_config))
    ws = session.file_by_id('1RFbedwlWR2I0d0ELllCeha9QCdZK_PQyJt_RcaerexU').worksheets.select do |sheet|
           sheet.title == 'outside_funds'
         end [0]
    # collection = session.collection_by_title("Static Content")

    values = {}
    # Dumps all cells.
    (1..ws.num_rows).each do |row|
      # p ws[row.to_s]
      (1..ws.num_cols).each do |col|
        if row == 0
          continue
        else
          values[ws[row, 1]] = ws[row, col]
        end
      end
    end
    values
  end
end

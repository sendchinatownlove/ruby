namespace :one_time_tasks do
  desc "Update all delivery types to include a delivery type id field"
  task build_delivery_types_from_scratch: :environment do
    DELIVERY_TYPE_IDS = [
      "phone",
      "caviar",
      "chowbus",
      "doordash",
      "grubhub",
      "hungrypanda",
      "postmates",
      "seamless",
      "ubereats"
    ]

    DELIVERY_TYPE_NAME = [
      "Phone",
      "Caviar",
      "Chowbus",
      "DoorDash",
      "Grubhub",
      "Hungry Panda",
      "Postmates",
      "Seamless",
      "Uber Eats",
    ]
    IMG_URL_PRE = "./assets"
    IMG_URL_SUFF = "@2x.png"
    DELIVERY_TYPE_IMG_URLS = [
      "#{IMG_URL_PRE}#{"Phone"}#{IMG_URL_SUFF}",
      "#{IMG_URL_PRE}#{"Caviar"}#{IMG_URL_SUFF}",
      "#{IMG_URL_PRE}#{"Chowbus"}#{IMG_URL_SUFF}",
      "#{IMG_URL_PRE}#{"Doordash"}#{IMG_URL_SUFF}",
      "#{IMG_URL_PRE}#{"Grubhub"}#{IMG_URL_SUFF}",
      "#{IMG_URL_PRE}#{"Hungry%20Panda"}#{IMG_URL_SUFF}",
      "#{IMG_URL_PRE}#{"Postmates"}#{IMG_URL_SUFF}",
      "#{IMG_URL_PRE}#{"Seamless"}#{IMG_URL_SUFF}",
      "#{IMG_URL_PRE}#{"UberEats"}#{IMG_URL_SUFF}",
    ]

    DELIVERY_TYPE_NAME.each.with_index do |type_name, index|
      delivery_type = DeliveryType.find_or_create_by(name: type_name)

      deliver_type.update(image_url: DELIVERY_TYPE_IMG_URLS[index], delivery_type_id: DELIVERY_TYPE_IDS[index])
    end
  end
end
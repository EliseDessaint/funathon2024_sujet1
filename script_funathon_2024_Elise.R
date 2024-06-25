#### sujet 1 FUNATHON 2024 : 
## Visualiser les émissions de C02 liées à une mesure de restriction de liaison 
## aérienne relativement à des durées de trajets ferroviaires.

#### récupération de l'environnement et des packages nécéssaires au projet
renv::restore()

### PARTIE 1 : API
### récupération des identifiants TravelTime sous fore d'un fichier yaml
library(yaml)


X_API_ID <- "7059a356"
X_API_KEY <- "c3f650d9ae79cb3fad346e5d42b3bb7a"

identif_TT<-as.yaml(c(X_API_ID, X_API_KEY))

writeLines(identif_TT, "secrets.yaml")

### modif du .gitignore en ajoutant le fichier yaml (directement dans le fichier)


### comm' avec l'API 
ROUTES_API_URL <-"https://api.traveltimeapp.com/v4/routes"

### récupération du corps de la requête du playground
corps_requete <- '{
  "locations": [
    {
      "id": "point-from",
      "coords": {
        "lat": 50.6365654,
        "lng": 3.0635282
      }
    },
    {
      "id": "point-to-1",
      "coords": {
        "lat": 48.8588897,
        "lng": 2.320041
      }
    }
  ],
  "departure_searches": [
    {
      "id": "departure-search",
      "transportation": {
        "type": "train"
      },
      "departure_location_id": "point-from",
      "arrival_location_ids": [
        "point-to-1"
      ],
      "departure_time": "2024-06-25T07:00:00.000Z",
      "properties": [
        "travel_time",
        "route"
      ],
      "range": {
        "enabled": true,
        "max_results": 5,
        "width": 900
      }
    }
  ]
}'


### parametrage préalable de l'accès à l'API
headers <- httr::add_headers(
  "Content-Type" = "application/json",
  "X-Application-Id" = X_API_ID,
  "X-Api-Key" = X_API_KEY
)

### envoi d' une requête test : on va utiliser ici la méthode POST, notamment 
### car on a besoin d’une authentification
reponse <- httr::POST(ROUTES_API_URL, body = corps_requete, encode = "json", headers)

contenu <- httr::content(reponse)

### vérification que les fichiers reponse et contenu sont bien ce qu'on attend

if (httr::status_code(reponse) == 200) {
  print("La requête a bien été traitée")
  #content <- httr::content(reponse, as = "parsed")
  #print(contenu)
} else {
  # Affichage d'un message d'erreur si le code de la réponse n'est pas 200
  print(sprintf("Une erreur est survenue. Code de la réponse : %d", httr::status_code(reponse)))
}
## c'est bon !!!


#### création d'une fonction get_travel_time_api_response() qui renvoie la 
### réponse de l’API de TravelTime pour un endpoint (=destination) et une requête donnés


get_travel_time_api_response <- function(api_url, request_body) {
  # On prépare les headers
  headers <- httr::add_headers(
    "Content-Type" = "application/json",
    "X-Application-Id" = X_API_ID,
    "X-Api-Key" = X_API_KEY
  )
  ## On envoie la requête avec les headers spécifiés
  response <- httr::POST(api_url, body = request_body, encode = "json", headers)
  
  # On vérifie s'il y a eu une erreur
  if (!httr::http_error(response)) {
    return(list(
      "Content" = httr::content(response, as = "parsed"),
      "Status_code" = httr::status_code(response)
    ))
  } else {
    # On affiche une message d'avertissement lorsque la requête n'a rien renvoyé
    warning("erreur : ", httr::http_status(response)$message)
    return(list(
      "Content" = NA,
      "Status_code" = httr::status_code(response)
    ))
  }
}

# test de la fonction avec les même paramètres :
test_function <- get_travel_time_api_response(ROUTES_API_URL, corps_requete)


## Explorer attentivement la réponse avec la fonction View puis affecter la liste des descriptions des itinéraires trouvés à une variable list_itinerary (liste nommée properties dans le JSON).

list_itineraire <- test_function[[1]]$results[[1]]$locations[[1]]$properties
print(list_itineraire)

{
  "results": [
    {
      "search_id": "departure-search",
      "locations": [
        {
          "id": "point-to-1",
          "properties": [
            {
              "travel_time": 5756,
              "route": {
                "departure_time": "2024-06-25T10:03:48+02:00",
                "arrival_time": "2024-06-25T11:39:44+02:00",
                "parts": [
                  {
                    "id": 0,
                    "type": "start_end",
                    "mode": "walk",
                    "directions": "Start your journey 12 meters northeast",
                    "distance": 12,
                    "travel_time": 9,
                    "coords": [
                      {
                        "lat": 50.6365654,
                        "lng": 3.0635282
                      },
                      {
                        "lat": 50.636636600000195,
                        "lng": 3.063669000000003
                      }
                    ],
                    "direction": "northeast"
                  },
                  {
                    "id": 1,
                    "type": "road",
                    "mode": "walk",
                    "directions": "Walk 21 meters",
                    "distance": 21,
                    "travel_time": 16,
                    "coords": [
                      {
                        "lat": 50.636636600000195,
                        "lng": 3.063669000000003
                      },
                      {
                        "lat": 50.63675160000026,
                        "lng": 3.0639230000000004
                      }
                    ]
                  },
                  {
                    "id": 2,
                    "type": "road",
                    "mode": "walk",
                    "directions": "Slight right onto Place du Général de Gaulle and walk 28 meters",
                    "distance": 28,
                    "travel_time": 21,
                    "coords": [
                      {
                        "lat": 50.63675160000026,
                        "lng": 3.0639230000000004
                      },
                      {
                        "lat": 50.636741800000195,
                        "lng": 3.0639403999999977
                      },
                      {
                        "lat": 50.63670640000019,
                        "lng": 3.064037999999998
                      },
                      {
                        "lat": 50.63669880000019,
                        "lng": 3.064089699999998
                      },
                      {
                        "lat": 50.63669960000019,
                        "lng": 3.064166999999998
                      },
                      {
                        "lat": 50.63671519999986,
                        "lng": 3.0642298999999875
                      },
                      {
                        "lat": 50.63674500000002,
                        "lng": 3.06428459999999
                      }
                    ],
                    "road": "Place du Général de Gaulle",
                    "turn": "slight_right"
                  },
                  {
                    "id": 3,
                    "type": "road",
                    "mode": "walk",
                    "directions": "Slight left onto Rue des Manneliers and walk 51 meters",
                    "distance": 51,
                    "travel_time": 37,
                    "coords": [
                      {
                        "lat": 50.63674500000002,
                        "lng": 3.06428459999999
                      },
                      {
                        "lat": 50.63696169999998,
                        "lng": 3.0647417999999957
                      },
                      {
                        "lat": 50.63701809999999,
                        "lng": 3.064871500000005
                      }
                    ],
                    "road": "Rue des Manneliers",
                    "turn": "slight_left"
                  },
                  {
                    "id": 4,
                    "type": "road",
                    "mode": "walk",
                    "directions": "Continue onto Rue Faidherbe for 281 meters",
                    "distance": 281,
                    "travel_time": 223,
                    "coords": [
                      {
                        "lat": 50.63701809999999,
                        "lng": 3.064871500000005
                      },
                      {
                        "lat": 50.63706430000017,
                        "lng": 3.064973599999994
                      },
                      {
                        "lat": 50.63712329999998,
                        "lng": 3.0651092999999956
                      },
                      {
                        "lat": 50.63714660000019,
                        "lng": 3.0652112999999983
                      },
                      {
                        "lat": 50.6371314,
                        "lng": 3.0653320999999916
                      },
                      {
                        "lat": 50.637120500000194,
                        "lng": 3.065418399999998
                      },
                      {
                        "lat": 50.637098700000266,
                        "lng": 3.0655914
                      },
                      {
                        "lat": 50.637094499999975,
                        "lng": 3.065624899999996
                      },
                      {
                        "lat": 50.636905500000154,
                        "lng": 3.0671266999999935
                      },
                      {
                        "lat": 50.6368648000002,
                        "lng": 3.067449499999998
                      },
                      {
                        "lat": 50.63669900000006,
                        "lng": 3.0687667000000145
                      }
                    ],
                    "road": "Rue Faidherbe",
                    "turn": "straight"
                  },
                  {
                    "id": 5,
                    "type": "road",
                    "mode": "walk",
                    "directions": "Turn left onto Rue du Priez and walk 3 meters",
                    "distance": 3,
                    "travel_time": 2,
                    "coords": [
                      {
                        "lat": 50.63669900000006,
                        "lng": 3.0687667000000145
                      },
                      {
                        "lat": 50.63672870000007,
                        "lng": 3.068770200000003
                      }
                    ],
                    "road": "Rue du Priez",
                    "turn": "left"
                  },
                  {
                    "id": 6,
                    "type": "road",
                    "mode": "walk",
                    "directions": "Turn right  and walk 60 meters",
                    "distance": 60,
                    "travel_time": 65,
                    "coords": [
                      {
                        "lat": 50.63672870000007,
                        "lng": 3.068770200000003
                      },
                      {
                        "lat": 50.63667619999998,
                        "lng": 3.0692222999999963
                      },
                      {
                        "lat": 50.636664199999984,
                        "lng": 3.0693274999999955
                      },
                      {
                        "lat": 50.636667299999985,
                        "lng": 3.0693529999999956
                      },
                      {
                        "lat": 50.63667729999992,
                        "lng": 3.0693737000000016
                      },
                      {
                        "lat": 50.636691699999986,
                        "lng": 3.0693922999999956
                      },
                      {
                        "lat": 50.63671559999992,
                        "lng": 3.0694054000000017
                      },
                      {
                        "lat": 50.636744199999974,
                        "lng": 3.0694262999999955
                      },
                      {
                        "lat": 50.63673439999996,
                        "lng": 3.0694605999999998
                      },
                      {
                        "lat": 50.636718700000046,
                        "lng": 3.069512299999996
                      },
                      {
                        "lat": 50.63670629999997,
                        "lng": 3.0695591999999956
                      }
                    ],
                    "turn": "right"
                  },
                  {
                    "id": 7,
                    "type": "road",
                    "mode": "walk",
                    "directions": "Turn left onto Place de la Gare and walk 33 meters",
                    "distance": 33,
                    "travel_time": 24,
                    "coords": [
                      {
                        "lat": 50.63670629999997,
                        "lng": 3.0695591999999956
                      },
                      {
                        "lat": 50.63675969999995,
                        "lng": 3.0696070000000013
                      },
                      {
                        "lat": 50.63680059999995,
                        "lng": 3.0696493000000014
                      },
                      {
                        "lat": 50.63682669999997,
                        "lng": 3.0696879999999958
                      },
                      {
                        "lat": 50.63685219999997,
                        "lng": 3.069734099999996
                      },
                      {
                        "lat": 50.63687369999995,
                        "lng": 3.0697749000000014
                      },
                      {
                        "lat": 50.636901199999954,
                        "lng": 3.0698404000000012
                      },
                      {
                        "lat": 50.63691859999995,
                        "lng": 3.0698900000000013
                      }
                    ],
                    "road": "Place de la Gare",
                    "turn": "left"
                  },
                  {
                    "id": 8,
                    "type": "road",
                    "mode": "walk",
                    "directions": "Turn right onto Place des Buisses and walk 76 meters",
                    "distance": 76,
                    "travel_time": 56,
                    "coords": [
                      {
                        "lat": 50.63691859999995,
                        "lng": 3.0698900000000013
                      },
                      {
                        "lat": 50.63684079999975,
                        "lng": 3.0699326999999954
                      },
                      {
                        "lat": 50.63679250000014,
                        "lng": 3.0703379000000073
                      },
                      {
                        "lat": 50.636795000000525,
                        "lng": 3.0703409999999955
                      },
                      {
                        "lat": 50.63679710000014,
                        "lng": 3.0703451000000075
                      },
                      {
                        "lat": 50.63679830000014,
                        "lng": 3.0703492000000074
                      },
                      {
                        "lat": 50.63679910000014,
                        "lng": 3.0703547000000073
                      },
                      {
                        "lat": 50.636798800000136,
                        "lng": 3.0703624000000076
                      },
                      {
                        "lat": 50.63679720000014,
                        "lng": 3.0703685000000074
                      },
                      {
                        "lat": 50.63679530000014,
                        "lng": 3.0703725000000075
                      },
                      {
                        "lat": 50.63679200000014,
                        "lng": 3.070376500000007
                      },
                      {
                        "lat": 50.63678990000014,
                        "lng": 3.0703780000000074
                      },
                      {
                        "lat": 50.63678770000014,
                        "lng": 3.0703790000000075
                      },
                      {
                        "lat": 50.63672560000011,
                        "lng": 3.0708747000000103
                      }
                    ],
                    "road": "Place des Buisses",
                    "turn": "right"
                  },
                  {
                    "id": 9,
                    "type": "road",
                    "mode": "walk",
                    "directions": "Turn right  and walk 24 meters",
                    "distance": 24,
                    "travel_time": 17,
                    "coords": [
                      {
                        "lat": 50.63672560000011,
                        "lng": 3.0708747000000103
                      },
                      {
                        "lat": 50.63661420000013,
                        "lng": 3.070815099999978
                      },
                      {
                        "lat": 50.6365749000001,
                        "lng": 3.070967299999979
                      }
                    ],
                    "turn": "right"
                  },
                  {
                    "id": 10,
                    "type": "basic",
                    "mode": "walk",
                    "directions": "",
                    "distance": 15,
                    "travel_time": 22,
                    "coords": [
                      {
                        "lat": 50.6365749000001,
                        "lng": 3.070967299999979
                      },
                      {
                        "lat": 50.63646,
                        "lng": 3.07084
                      }
                    ]
                  },
                  {
                    "id": 11,
                    "type": "public_transport",
                    "mode": "train",
                    "directions": "Take a train (251A / Paris - Lille (of SNCF) line) from 'Lille Flandres' (leaves at 10:12) to 'Paris Gare du Nord' (arrives at 11:14) (1 stops)",
                    "distance": 0,
                    "travel_time": 3720,
                    "coords": [
                      {
                        "lat": 50.63646,
                        "lng": 3.07084
                      },
                      {
                        "lat": 48.880398,
                        "lng": 2.354973
                      }
                    ],
                    "line": "251A / Paris - Lille (of SNCF)",
                    "departure_station": "Lille Flandres",
                    "arrival_station": "Paris Gare du Nord",
                    "departs_at": "10:12",
                    "arrives_at": "11:14",
                    "num_stops": 1
                  },
                  {
                    "id": 12,
                    "type": "basic",
                    "mode": "walk",
                    "directions": "Leave Paris Gare du Nord",
                    "distance": 10,
                    "travel_time": 16,
                    "coords": [
                      {
                        "lat": 48.880398,
                        "lng": 2.354973
                      },
                      {
                        "lat": 48.88030600000018,
                        "lng": 2.3549207999999937
                      }
                    ]
                  },
                  {
                    "id": 13,
                    "type": "road",
                    "mode": "walk",
                    "directions": "Walk 166 meters",
                    "distance": 166,
                    "travel_time": 120,
                    "coords": [
                      {
                        "lat": 48.88030600000018,
                        "lng": 2.3549207999999937
                      },
                      {
                        "lat": 48.880136299999975,
                        "lng": 2.3548272000000057
                      },
                      {
                        "lat": 48.880122600000185,
                        "lng": 2.354819899999994
                      },
                      {
                        "lat": 48.879998100000186,
                        "lng": 2.354752999999994
                      },
                      {
                        "lat": 48.87996530000002,
                        "lng": 2.3549091000000097
                      },
                      {
                        "lat": 48.87994570000005,
                        "lng": 2.3550256000000096
                      },
                      {
                        "lat": 48.87992370000002,
                        "lng": 2.35515590000001
                      },
                      {
                        "lat": 48.87989230000002,
                        "lng": 2.35534730000001
                      },
                      {
                        "lat": 48.87986590000002,
                        "lng": 2.35558200000001
                      },
                      {
                        "lat": 48.87984410000005,
                        "lng": 2.35578630000001
                      },
                      {
                        "lat": 48.87983350000002,
                        "lng": 2.35588640000001
                      },
                      {
                        "lat": 48.879782700000064,
                        "lng": 2.3561288000000093
                      },
                      {
                        "lat": 48.87977110000002,
                        "lng": 2.3561842000000097
                      },
                      {
                        "lat": 48.87971010000002,
                        "lng": 2.3564695000000095
                      },
                      {
                        "lat": 48.87970910000002,
                        "lng": 2.3564899000000095
                      },
                      {
                        "lat": 48.879711800000024,
                        "lng": 2.3565111000000094
                      }
                    ]
                  },
                  {
                    "id": 14,
                    "type": "basic",
                    "mode": "walk",
                    "directions": "",
                    "distance": 29,
                    "travel_time": 42,
                    "coords": [
                      {
                        "lat": 48.879711800000024,
                        "lng": 2.3565111000000094
                      },
                      {
                        "lat": 48.879510553130615,
                        "lng": 2.356768884572096
                      }
                    ]
                  },
                  {
                    "id": 15,
                    "type": "public_transport",
                    "mode": "rail_underground",
                    "directions": "Take a train (4 / 4 (of RATP) line) from 'Gare du Nord' (leaves at 11:17) to 'Strasbourg - Saint-Denis' (arrives at 11:21) (3 stops)",
                    "distance": 0,
                    "travel_time": 242,
                    "coords": [
                      {
                        "lat": 48.879510553130615,
                        "lng": 2.356768884572096
                      },
                      {
                        "lat": 48.87627821831841,
                        "lng": 2.3577495818204395
                      },
                      {
                        "lat": 48.87247308911766,
                        "lng": 2.3559014497805357
                      },
                      {
                        "lat": 48.86966773787259,
                        "lng": 2.3543411093711257
                      }
                    ],
                    "line": "4 / 4 (of RATP)",
                    "departure_station": "Gare du Nord",
                    "arrival_station": "Strasbourg - Saint-Denis",
                    "departs_at": "11:17",
                    "arrives_at": "11:21",
                    "num_stops": 3
                  },
                  {
                    "id": 16,
                    "type": "basic",
                    "mode": "walk",
                    "directions": "Enter 'station'",
                    "distance": 38,
                    "travel_time": 55,
                    "coords": [
                      {
                        "lat": 48.86966773787259,
                        "lng": 2.3543411093711257
                      },
                      {
                        "lat": 48.86944639999988,
                        "lng": 2.3542231000000373
                      },
                      {
                        "lat": 48.869380780106006,
                        "lng": 2.3540796521963494
                      }
                    ]
                  },
                  {
                    "id": 17,
                    "type": "public_transport",
                    "mode": "rail_underground",
                    "directions": "Take a train (8 / (BALARD <-> POINTE DU LAC) - Retour (of RATP (100)) line) from 'Strasbourg-Saint-Denis' (leaves at 11:22) to 'Invalides' (arrives at 11:31) (7 stops)",
                    "distance": 0,
                    "travel_time": 545,
                    "coords": [
                      {
                        "lat": 48.869380780106006,
                        "lng": 2.3540796521963494
                      },
                      {
                        "lat": 48.87057675358199,
                        "lng": 2.348494293710928
                      },
                      {
                        "lat": 48.87157474359305,
                        "lng": 2.3428950319846593
                      },
                      {
                        "lat": 48.87200623896137,
                        "lng": 2.339911390610416
                      },
                      {
                        "lat": 48.87063108014849,
                        "lng": 2.331737048361137
                      },
                      {
                        "lat": 48.86950712762907,
                        "lng": 2.324680199591515
                      },
                      {
                        "lat": 48.865507221530486,
                        "lng": 2.3203628558611284
                      },
                      {
                        "lat": 48.86109346762053,
                        "lng": 2.3146433553464374
                      }
                    ],
                    "line": "8 / (BALARD <-> POINTE DU LAC) - Retour (of RATP (100))",
                    "departure_station": "Strasbourg-Saint-Denis",
                    "arrival_station": "Invalides",
                    "departs_at": "11:22",
                    "arrives_at": "11:31",
                    "num_stops": 7
                  },
                  {
                    "id": 18,
                    "type": "basic",
                    "mode": "walk",
                    "directions": "Leave Invalides",
                    "distance": 27,
                    "travel_time": 39,
                    "coords": [
                      {
                        "lat": 48.86109346762053,
                        "lng": 2.3146433553464374
                      },
                      {
                        "lat": 48.8609738,
                        "lng": 2.3149665000000006
                      }
                    ]
                  },
                  {
                    "id": 19,
                    "type": "road",
                    "mode": "walk",
                    "directions": "Walk 3 meters along Rue de l'Université",
                    "distance": 3,
                    "travel_time": 3,
                    "coords": [
                      {
                        "lat": 48.8609738,
                        "lng": 2.3149665000000006
                      },
                      {
                        "lat": 48.86097080000005,
                        "lng": 2.315018699999995
                      }
                    ],
                    "road": "Rue de l'Université"
                  },
                  {
                    "id": 20,
                    "type": "road",
                    "mode": "walk",
                    "directions": "Turn right onto Rue de Constantine and walk 111 meters",
                    "distance": 111,
                    "travel_time": 80,
                    "coords": [
                      {
                        "lat": 48.86097080000005,
                        "lng": 2.315018699999995
                      },
                      {
                        "lat": 48.860891100000075,
                        "lng": 2.3150086000000023
                      },
                      {
                        "lat": 48.859965000000045,
                        "lng": 2.314895199999995
                      }
                    ],
                    "road": "Rue de Constantine",
                    "turn": "right"
                  },
                  {
                    "id": 21,
                    "type": "road",
                    "mode": "walk",
                    "directions": "Turn left onto Rue Saint-Dominique and walk 405 meters",
                    "distance": 405,
                    "travel_time": 371,
                    "coords": [
                      {
                        "lat": 48.859965000000045,
                        "lng": 2.314895199999995
                      },
                      {
                        "lat": 48.85996540000012,
                        "lng": 2.3149524000000086
                      },
                      {
                        "lat": 48.8599515999993,
                        "lng": 2.315552299999987
                      },
                      {
                        "lat": 48.85992250000008,
                        "lng": 2.3169823000000047
                      },
                      {
                        "lat": 48.85991159999993,
                        "lng": 2.317087699999999
                      },
                      {
                        "lat": 48.85980959999872,
                        "lng": 2.3180768000000187
                      },
                      {
                        "lat": 48.85979940000008,
                        "lng": 2.318156400000005
                      },
                      {
                        "lat": 48.859784099999075,
                        "lng": 2.318244699999985
                      },
                      {
                        "lat": 48.85956840000023,
                        "lng": 2.3190146999999826
                      },
                      {
                        "lat": 48.85940539999906,
                        "lng": 2.319477199999985
                      },
                      {
                        "lat": 48.85937630000023,
                        "lng": 2.3195586999999827
                      },
                      {
                        "lat": 48.859328399999065,
                        "lng": 2.319694099999985
                      },
                      {
                        "lat": 48.859266800000135,
                        "lng": 2.319857800000005
                      },
                      {
                        "lat": 48.85919619999907,
                        "lng": 2.3200452999999848
                      },
                      {
                        "lat": 48.859140000000075,
                        "lng": 2.320209100000005
                      }
                    ],
                    "road": "Rue Saint-Dominique",
                    "turn": "left"
                  },
                  {
                    "id": 22,
                    "type": "road",
                    "mode": "walk",
                    "directions": "Turn right onto Rue Casimir Périer and walk 5 meters",
                    "distance": 5,
                    "travel_time": 14,
                    "coords": [
                      {
                        "lat": 48.859140000000075,
                        "lng": 2.320209100000005
                      },
                      {
                        "lat": 48.859094999999066,
                        "lng": 2.3201757999999852
                      }
                    ],
                    "road": "Rue Casimir Périer",
                    "turn": "right"
                  },
                  {
                    "id": 23,
                    "type": "start_end",
                    "mode": "walk",
                    "directions": "Your destination is 24 meters southwest",
                    "distance": 24,
                    "travel_time": 17,
                    "coords": [
                      {
                        "lat": 48.859094999999066,
                        "lng": 2.3201757999999852
                      },
                      {
                        "lat": 48.8588897,
                        "lng": 2.320041
                      }
                    ],
                    "direction": "southwest"
                  }
                ]
              }
            }
          ]
        }
      ],
      "unreachable": []
    }
  ]
}
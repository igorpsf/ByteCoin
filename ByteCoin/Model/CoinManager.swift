//
//  CoinManager.swift
//  ByteCoin
//
//  Created by Igor Postnikov on 05/20/2021.
//  Copyright © 2019 The App Brewery. All rights reserved.
//

import Foundation

//By convention, Swift protocols are usually written in the file that has the class/struct which will call the
//delegate methods, i.e. the CoinManager.
protocol CoinManagerDelegate {
    
    //Create the method stubs wihtout implementation in the protocol.
    //It's usually a good idea to also pass along a reference to the current class.
    //e.g. func didUpdatePrice(_ coinManager: CoinManager, price: String, currency: String)
    //Check the Clima module for more info on this.
    func didUpdatePrice(price: String, currency: String)
    func didFailWithError(error: Error)
}

struct CoinManager {
    
    //Create an optional delegate that will have to implement the delegate methods.
    //Which we can notify when we have updated the price.
    var delegate: CoinManagerDelegate?
    
    let baseURL = "https://rest.coinapi.io/v1/exchangerate/BTC"
    let apiKey = "B0227E9A-F563-46A6-A33B-7EDC7E7B75FE"
    
    let currencyArray = ["AUD", "BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR"]

    func getCoinPrice(for currency: String) {
            
            let urlString = "\(baseURL)/\(currency)?apikey=\(apiKey)"

            if let url = URL(string: urlString) {
                
                let session = URLSession(configuration: .default)
                let task = session.dataTask(with: url) { (data, response, error) in
                    if error != nil {
                        self.delegate?.didFailWithError(error: error!)
                        return
                    }
                    
                    if let safeData = data {
                        
                        if let bitcoinPrice = self.parseJSON(safeData) {
                            
                            //Optional: round the price down to 2 decimal places.
                            let priceString = String(format: "%.2f", bitcoinPrice)
                            
                            //Call the delegate method in the delegate (ViewController) and
                            //pass along the necessary data.
                            self.delegate?.didUpdatePrice(price: priceString, currency: currency)
                        }
                    }
                }
                task.resume()
            }
        }
    
    func parseJSON(_ data: Data) -> Double? {
            
            //Create a JSONDecoder
            let decoder = JSONDecoder()
            do {
                
                //try to decode the data using the CoinData structure
                let decodedData = try decoder.decode(CoinData.self, from: data)
                
                //Get the last property from the decoded data.
                let lastPrice = decodedData.rate
                print(lastPrice)
                
                print(decodedData.time)
                print(decodedData.asset_id_base)
                print(decodedData.asset_id_quote)
                print(decodedData.rate)
                
                return lastPrice
                
            } catch {
                
                //Catch and print any errors.
                print(error)
                return nil
            }
        }
    
}

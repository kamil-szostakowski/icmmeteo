//
//  MMTCommentStore.swift
//  MobileMeteo
//
//  Created by szostakowskik on 20.02.2018.
//  Copyright © 2018 Kamil Szostakowski. All rights reserved.
//

typealias MMTFetchCommentCompletion = (_ comment: NSAttributedString?, _ error: MMTError?) -> Void

class MMTForecasterCommentStore
{
    func getForecasterComment(completion: @escaping MMTFetchCommentCompletion)
    {
        let htmlString = "<div style=\"padding: 15px; background-color:#fff; background-color:rgba(255,255,255,0.6); margin:10px; border-radius: 10px;\">Na mapach ciśnienia w obszarze naszych modeli dominują wysokie jego wartości, ale pole ciśnienia stale ewoluuje wokół wyżu skandynawskiego, który utrzymywać się będzie przez znacznie dłuższy czas aniżeli horyzont czasowy obu naszych modeli, a to oznacza, że zablokowana będzie strefowa cyrkulacja atmosfery nad znacznym obszarem kontynent europejskiego, a w tym także nad naszym krajem. Jedynie południe kontynentu, z uwagi na rozległy akwen Morza Śródziemnego, stwarzający dogodne warunki do generowania się ośrodków niżowych, a następnie ich utrzymywania się, pozostawać będzie ciepłym obszarem naszego kontynentu, czemu także sprzyjać będą znacznie niższe szerokości geograficzne i bliskie sąsiedztwo suchych obszarów Afryki północnej.<p> Po stosunkowo długim okresie, bo sięgającym nieco ponad miesiąc, mamy przedsmak zimy, co prawda suchej i bez pokrywy śnieżnej na znacznym obszarze (<a href=\"http://old.wetterzentrale.de/topkarten/fsdivka.html),\">old.wetterzentrale.de/topkarten...</a> ale mroźnej z temperaturą dzisiejszego poranka zbliżoną do minus 10 stopni na naszym południowym wschodzie, o godzinie 6-tej na stacjach meteorologicznych IMGW w tym obszarze zarejestrowano: w Krośnie -8,9, w Nowym Sączu -9,0, w Zakopanem -9,6, w Przemyślu -9,8, w Lesku -9,9, a w Zamościu -11,7 ºC, ale w tym samym czasie na Kasprowym Wierchu było tylko -7,8, a wczoraj -14,3 ºC. Taki spadek temperatury to nie tylko czynnik adwekcyjny, a w znacznej mierze czynnik radiacyjny, który uaktywnił się po ustąpieniu zachmurzenia w porze nocnej. Z kolei duży wzrost temperatury w ciągu ostatniej doby na Kasprowym Wierchu, to efekt adwekcji ciepła płynącego górą z południa kontynentu, w przedniej części górnej zatoki sięgającej na południu aż po Afrykę północno zachodnią (<a href=\"http://www1.wetter3.de/animation.html).\">www1.wetter3.de/animation.html).</a></p><p> Najbliższej nocy ośrodek chłodu przesunie się nad środkowy wschód i będzie to związane z nasunięciem się od południa zachmurzenia z opadami słabego śniegu wyrzucanego siłą odśrodkową wiru niżowego znad Morza Śródziemnego. Z kolei następnej nocy ośrodek ten przesunie się na północny wschód, po ustąpieniu z tego obszaru zachmurzenia z opadami słabego śniegu spychanego przez wiatr północno wschodni.</p><p> Mróz, o którym tu mowa to przedsmak tego co przed nami już w końcu tego tygodnia, kiedy to ujemna temperatura utrzymywać się będzie przez całą dobę na obszarze całego kraju (<a href=\"http://www1.wetter3.de/animation.html),\">www1.wetter3.de/animation.html),</a> a adwekcja zimnego powietrza od północnego wschodu i wschodu będzie powodowała dalszy spadek temperatury. Można by powiedzieć, że zima dopiero przed nami.</p><p>Ryszard Olędzki</p><p> 20 lutego 2018r., 07:15</p></div>"
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime(uptimeNanoseconds: 5000)) {
            completion(try! NSAttributedString(htmlString: htmlString), nil)
            //        completion(nil, .commentFetchFailure)

        }
    }
}

extension NSAttributedString
{
    convenience init(htmlString html: String) throws
    {
        try self.init(data: Data(html.utf8), options: [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
            ], documentAttributes: nil)
    }
    
}

﻿
&НаКлиенте
Процедура ОбработкаКоманды(ПараметрКоманды, ПараметрыВыполненияКоманды)
    ПодключитьВнешнююОбработкуНаСервере();
    ОткрытьФорму("ВнешняяОбработка.StandardDocumentsPosting.Форма");
КонецПроцедуры

&НаСервере
Процедура ПодключитьВнешнююОбработкуНаСервере()
    ВнешниеОбработки.Подключить("v8res://mngbase/StandardDocumentsPosting.epf", "StandardDocumentsPosting", false);
КонецПроцедуры
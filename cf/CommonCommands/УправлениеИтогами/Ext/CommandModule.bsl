﻿
&НаКлиенте
Процедура ОбработкаКоманды(ПараметрКоманды, ПараметрыВыполненияКоманды)
    ПодключитьВнешнююОбработкуНаСервере();
    ОткрытьФорму("ВнешняяОбработка.StandardTotalsManagement.Форма");
КонецПроцедуры

&НаСервере
Процедура ПодключитьВнешнююОбработкуНаСервере()
    ВнешниеОбработки.Подключить("v8res://mngbase/StandardTotalsManagement.epf", "StandardTotalsManagement", false);
КонецПроцедуры
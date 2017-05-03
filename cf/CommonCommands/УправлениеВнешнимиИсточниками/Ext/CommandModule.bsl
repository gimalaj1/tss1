
&НаКлиенте
Процедура ОбработкаКоманды(ПараметрКоманды, ПараметрыВыполненияКоманды)
    ПодключитьВнешнююОбработкуНаСервере();
    ОткрытьФорму("ВнешняяОбработка.StandardExternalDataSourcesManagement.Форма");
КонецПроцедуры

&НаСервере
Процедура ПодключитьВнешнююОбработкуНаСервере()
    ВнешниеОбработки.Подключить("v8res://mngbase/StandardExternalDataSourcesManagement.epf", "StandardExternalDataSourcesManagement", false);
КонецПроцедуры
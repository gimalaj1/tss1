﻿
&НаКлиенте
Процедура ОбработкаКоманды(ПараметрКоманды, ПараметрыВыполненияКоманды)

	ТабДок = Новый ТабличныйДокумент;
	Печать_Накладной(ТабДок, ПараметрКоманды);

	ТабДок.ОтображатьСетку     = Ложь;
	ТабДок.Защита              = Ложь;
	ТабДок.ТолькоПросмотр      = Ложь;
	ТабДок.ОтображатьЗаголовки = Ложь;
	ТабДок.Показать();

КонецПроцедуры

&НаСервере
Процедура Печать_Накладной(ТабДок, ПараметрКоманды)
	
	Документы.СписаниеТоваров.Печать_Накладной(ТабДок, ПараметрКоманды);
	
КонецПроцедуры

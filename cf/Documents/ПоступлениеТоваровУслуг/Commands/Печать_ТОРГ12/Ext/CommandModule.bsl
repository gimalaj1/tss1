﻿
&НаКлиенте
Процедура ОбработкаКоманды(ПараметрКоманды, ПараметрыВыполненияКоманды)
	//{{_КОНСТРУКТОР_ПЕЧАТИ(Печать_ТОРГ12)
	ТабДок = Новый ТабличныйДокумент;
	Печать_ТОРГ12(ТабДок, ПараметрКоманды);

	ТабДок.ОтображатьСетку = Ложь;
	ТабДок.Защита = Ложь;
	ТабДок.ТолькоПросмотр = Ложь;
	ТабДок.ОтображатьЗаголовки = Ложь;
	ТабДок.Показать();
	//}}
КонецПроцедуры

&НаСервере
Процедура Печать_ТОРГ12(ТабДок, ПараметрКоманды)
	Документы.ПоступлениеТоваровУслуг.Печать_ТОРГ12(ТабДок, ПараметрКоманды);
КонецПроцедуры

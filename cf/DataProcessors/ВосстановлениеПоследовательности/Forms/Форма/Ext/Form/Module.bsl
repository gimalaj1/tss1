﻿
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	Объект.ТекущаяДатаПоследовательности = Последовательности.ОсновнаяПоследовательность.ПолучитьГраницу();
КонецПроцедуры

&НаСервере
Процедура ВосстановитьПоследовательностьНаСервере()
	Последовательности.ОсновнаяПоследовательность.Восстановить(ТекущаяДата());  
	Объект.ТекущаяДатаПоследовательности = Последовательности.ОсновнаяПоследовательность.ПолучитьГраницу();
КонецПроцедуры

&НаКлиенте
Процедура ВосстановитьПоследовательность(Команда)
	ВосстановитьПоследовательностьНаСервере();
КонецПроцедуры

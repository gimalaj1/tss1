﻿
Процедура ОбработкаЗаполнения(ДанныеЗаполнения, СтандартнаяОбработка)
	
	Если ТипЗнч(ДанныеЗаполнения) = Тип("СправочникСсылка.Контрагенты") Тогда
		// Заполнение шапки
		Владелец = ДанныеЗаполнения.Ссылка;
	КонецЕсли;
	
КонецПроцедуры

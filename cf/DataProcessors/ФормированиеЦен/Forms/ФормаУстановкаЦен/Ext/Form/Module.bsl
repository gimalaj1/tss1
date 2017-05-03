﻿
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)	
	
	Элементы.Номенклатура.Доступность 		= Ложь;
	Элементы.Документ.Доступность 			= Ложь;
	Элементы.ВидЦены1.Доступность 			= Ложь;
	Элементы.ВидЦены2.Доступность 			= Ложь;
	Элементы.ВидЦены3.Доступность 			= Ложь;
	Элементы.Округление.Доступность 		= Ложь;
	Элементы.Знак.Доступность 				= Ложь;
	Элементы.Число.Доступность 				= Ложь;
	Элементы.СуммаИлиПроцент.Доступность 	= Ложь;
	
	БулевоПоОстаткам 						= Истина;
	Знак									= "+";
	СуммаИлиПроцент							= "+";
	Округление					 			= "БезОкругления";	
	ДатаЦен 								= ТекущаяДата();
	
	ЗаполнитьТЗВидыЦен();	
	
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьТЗВидыЦен()
	
	ВидыЦен.Очистить();
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	ВидыЦен.Ссылка
	|ИЗ
	|	Справочник.ВидыЦен КАК ВидыЦен";	
	РезультатЗапроса = Запрос.Выполнить();	
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();	
	Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
		СтрокаВидЦены = ВидыЦен.Добавить();
		СтрокаВидЦены.ВидЦены = ВыборкаДетальныеЗаписи.Ссылка;
	КонецЦикла;
	
КонецПроцедуры


&НаКлиенте
Процедура СформироватьСписок(Команда)
	
	Отказ = Ложь;
	ОчиститьСообщения();
	
	ВыбраныЦены = Ложь;
	Для Каждого Стр из ВидыЦен Цикл
		Если Стр.Выбран Тогда
			ВыбраныЦены = Истина;
			Прервать;
		КонецЕсли;		
	КонецЦикла;
	
	Если НЕ ВыбраныЦены Тогда
		Сообщить("Не выбран вид цен!");
		Отказ = Истина;
	КонецЕсли;
	
	Если БулевоПоДокументу и Не ЗначениеЗаполнено(Документ) Тогда
		Сообщить("Не выбран документ!");
		Отказ = Истина;
	КонецЕсли;
	
	Если НЕ Отказ Тогда	
		СформироватьСписокНаСервере();
	КонецЕсли;
	
КонецПроцедуры
&НаСервере
Процедура СформироватьСписокНаСервере()
	
	ТЗ.Очистить();	
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	СпрНомен.Ссылка,
	|	ЦеныНоменклатурыСрезПоследних.ВидЦены,
	|	ЦеныНоменклатурыСрезПоследних.Цена,
	|	ПартииТоваровОстатки.СуммаОстаток / ПартииТоваровОстатки.КоличествоОстаток КАК Себестоимость
	|ИЗ
	|	РегистрСведений.ЦеныНоменклатуры.СрезПоследних(, ВидЦены В (&ВидЦены)) КАК ЦеныНоменклатурыСрезПоследних
	|		ПОЛНОЕ СОЕДИНЕНИЕ Справочник.Номенклатура КАК СпрНомен
	|			ЛЕВОЕ СОЕДИНЕНИЕ РегистрНакопления.ПартииТоваров.Остатки КАК ПартииТоваровОстатки
	|			ПО (ПартииТоваровОстатки.Номенклатура = СпрНомен.Ссылка)
	|		ПО ЦеныНоменклатурыСрезПоследних.Номенклатура = СпрНомен.Ссылка
	|ГДЕ
	|	СпрНомен.ЭтоГруппа = ЛОЖЬ
	|	И СпрНомен.ПометкаУдаления = ЛОЖЬ";
	
	Если БулевоПоНоменклатуре Тогда 
		Запрос.Текст = Запрос.Текст + Символы.ПС+"И СпрНомен.Ссылка В ИЕРАРХИИ(&Ссылка)";
		Запрос.УстановитьПараметр("Ссылка", Номенклатура);
	КонецЕсли;
	
	Если БулевоПоДокументу Тогда 
		Запрос.Текст = Запрос.Текст + Символы.ПС+"И СпрНомен.Ссылка В ИЕРАРХИИ(&ДокументТовары)";
		Запрос.УстановитьПараметр("ДокументТовары", Документ.Товары.ВыгрузитьКолонку("Номенклатура")); 
	КонецЕсли;
	
	Если БулевоПоОстаткам Тогда 
		Запрос.Текст = Запрос.Текст + Символы.ПС+"И ПартииТоваровОстатки.КоличествоОстаток > 0";
	КонецЕсли;
	
	Запрос.УстановитьПараметр("Период", КонецДня(ДатаЦен));
	Запрос.УстановитьПараметр("ВидЦены", ПолучитьМассивВыбранныхВидовЦен());
	
	РезультатЗапроса = Запрос.Выполнить();	
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();	
	Пока ВыборкаДетальныеЗаписи.Следующий() Цикл 		
		
		ПараметрыОтбора = Новый Структура;
		ПараметрыОтбора.Вставить("Номенклатура", ВыборкаДетальныеЗаписи.Ссылка);
		НайденныеСтроки = ТЗ.НайтиСтроки(ПараметрыОтбора);
		
		Если НайденныеСтроки.Количество() = 0 Тогда
			СтрокаТЗ 				= ТЗ.Добавить();
			СтрокаТЗ.Выбран 	  	= Истина;
			СтрокаТЗ.Номенклатура 	= ВыборкаДетальныеЗаписи.Ссылка;
			СтрокаТЗ.ТЗСебестоимость_Цена 	= ВыборкаДетальныеЗаписи.Себестоимость;
			
			Если ЗначениеЗаполнено(ВыборкаДетальныеЗаписи.ВидЦены) Тогда 
				СтрокаТЗ["ТЗ"+ВыборкаДетальныеЗаписи.ВидЦены+"_Цена"] = ВыборкаДетальныеЗаписи.Цена;
				//СтрокаТЗ["ТЗ"+ВыборкаДетальныеЗаписи.ВидЦены+"_НоваяЦена"] = ВыборкаДетальныеЗаписи.Цена;
			КонецЕсли;
			
		Иначе
			Если ЗначениеЗаполнено(ВыборкаДетальныеЗаписи.ВидЦены) Тогда
				НайденныеСтроки[0]["ТЗ"+ВыборкаДетальныеЗаписи.ВидЦены+"_Цена"] = ВыборкаДетальныеЗаписи.Цена;
				//НайденныеСтроки[0]["ТЗ"+ВыборкаДетальныеЗаписи.ВидЦены+"_НоваяЦена"] = ВыборкаДетальныеЗаписи.Цена;
			КонецЕсли;
		КонецЕсли;
		
	КонецЦикла;	
	
КонецПроцедуры
&НаСервере
Функция ПолучитьМассивВыбранныхВидовЦен()
	
	Масс = Новый Массив;
	Для Каждого Стр из ВидыЦен Цикл
		Если Стр.Выбран Тогда
			Масс.Добавить(Стр.ВидЦены);
		КонецЕсли;		
	КонецЦикла;	
	
	Возврат Масс;
	
КонецФункции












&НаКлиенте
Процедура ПриИзмененииКолонкиТабличногоПоля(Элемент)
	
	ТекДанные = Элементы.ТЗ.ТекущиеДанные;
	
	ВидЦеныСтрокой = Сред(Элемент.Имя,Найти(Элемент.Имя,"_")+1);
	ВидЦеныСтрокой = Сред(ВидЦеныСтрокой,0,Найти(ВидЦеныСтрокой,"_")-1);
	
	Если ЗначениеЗаполнено(ТекДанные["ТЗ"+ВидЦеныСтрокой+"_Цена"]) Тогда
		Если Найти(Элемент.Имя,"Процент") > 0 Тогда
			Если ЗначениеЗаполнено(ТекДанные["ТЗ"+ВидЦеныСтрокой+"_Процент"]) Тогда
				ТекДанные["ТЗ"+ВидЦеныСтрокой+"_НоваяЦена"] = ТекДанные["ТЗ"+ВидЦеныСтрокой+"_Цена"] + (ТекДанные["ТЗ"+ВидЦеныСтрокой+"_Цена"] / 100 * ТекДанные["ТЗ"+ВидЦеныСтрокой+"_Процент"]);
			Иначе
				ТекДанные["ТЗ"+ВидЦеныСтрокой+"_НоваяЦена"] = 0;
			КонецЕсли;
		
		Иначе //Изменена НоваяЦена
			Если ЗначениеЗаполнено(ТекДанные["ТЗ"+ВидЦеныСтрокой+"_НоваяЦена"]) Тогда
				ТекДанные["ТЗ"+ВидЦеныСтрокой+"_Процент"] = (ТекДанные["ТЗ"+ВидЦеныСтрокой+"_НоваяЦена"] - ТекДанные["ТЗ"+ВидЦеныСтрокой+"_Цена"]) / (ТекДанные["ТЗ"+ВидЦеныСтрокой+"_Цена"] / 100);
			Иначе
				ТекДанные["ТЗ"+ВидЦеныСтрокой+"_Процент"] = 0;
			КонецЕсли;   			
		КонецЕсли;
		
		Если БулевоОкругление и Строка(ВидЦены3) = ВидЦеныСтрокой Тогда			
			ТекДанные["ТЗ"+ВидЦеныСтрокой+"_НоваяЦена"] = Округлить(ТекДанные["ТЗ"+ВидЦеныСтрокой+"_НоваяЦена"]);
		КонецЕсли; 		
	
	Иначе
		//Установлена новая цена
	КонецЕсли;
	
	Элементы["ТЗ_"+ВидЦеныСтрокой+"_Процент"].Шрифт = Новый Шрифт(,,Истина);
	
КонецПроцедуры

&НаКлиенте
Функция Округлить(Цена)
	
	Если Округление = "0,10" Тогда  
		Цена = Окр(Цена,1);
	ИначеЕсли Округление = "1" Тогда
		Цена = Окр(Цена);
	ИначеЕсли Округление = "10"  Тогда
		Цена = Окр(Цена,-1);
	ИначеЕсли Округление = "100"  Тогда
		Цена = Окр(Цена,-2);
	Иначе
		//БезОкругления
	КонецЕсли; 			
	
	Возврат Цена;
	
КонецФункции







&НаКлиенте
Процедура ВидыЦенПриИзменении(Элемент)
	
	ТЗ.Очистить();
	
	//Заполение значениями 2 реквизита ВидЦены1 и ВидЦены2
	Элементы.ВидЦены1.СписокВыбора.Очистить();
	Элементы.ВидЦены2.СписокВыбора.Очистить();
	Элементы.ВидЦены3.СписокВыбора.Очистить();
	Элементы.ВидЦены2.СписокВыбора.Добавить("Себестоимость");
	Для Каждого Стр из ВидыЦен Цикл
		Если Стр.Выбран Тогда
			Элементы.ВидЦены1.СписокВыбора.Добавить(Стр.ВидЦены);
			Элементы.ВидЦены2.СписокВыбора.Добавить(Стр.ВидЦены);
			Элементы.ВидЦены3.СписокВыбора.Добавить(Стр.ВидЦены);
		КонецЕсли;                                    
	КонецЦикла;
	
	ВидыЦенПриИзмененииНаСервере();
	
КонецПроцедуры 
&НаСервере
Процедура ВидыЦенПриИзмененииНаСервере() 	
	
	//УдалитьВсеРанееСозданныеКолонки
	Для Каждого Стр из ВидыЦен Цикл
		Если Элементы.Найти("ТЗ_"+Стр.ВидЦены) <> Неопределено Тогда   //НЕ Стр.Выбран и 
			Элементы.Удалить(Элементы.Найти("ТЗ_"+Стр.ВидЦены));
			//Элементы.Удалить(Элементы.Найти("ТЗ_"+Стр.ВидЦены+"Цена"));
			//Элементы.Удалить(Элементы.Найти("ТЗ_"+Стр.ВидЦены+"НоваяЦена"));
			//Элементы.Удалить(Элементы.Найти("ТЗ_"+Стр.ВидЦены+"Процент"));
		КонецЕсли;
	КонецЦикла;
	
	Сч = 0;
	Для Каждого Стр из ВидыЦен Цикл		
		
		Если НЕ Стр.Выбран Тогда
			Продолжить;
		КонецЕсли;
		
		Сч = Сч + 1;
		
		нРеквизиты = Новый Массив;              //Имя        			 Тип                        					  Путь  Заголовок     			 СохраняемыеДанные
		КвалификаторыЧисла = Новый КвалификаторыЧисла(10, 2, ДопустимыйЗнак.Любой);
		нРеквизиты.Добавить(Новый РеквизитФормы("ТЗ"+Стр.ВидЦены+"_Цена", Новый ОписаниеТипов("Число",КвалификаторыЧисла), "ТЗ", "ТЗ"+Стр.ВидЦены+"_Цена", Истина));
		нРеквизиты.Добавить(Новый РеквизитФормы("ТЗ"+Стр.ВидЦены+"_НоваяЦена", Новый ОписаниеТипов("Число",КвалификаторыЧисла), "ТЗ", "ТЗ"+Стр.ВидЦены+"_НоваяЦена", Истина));
		нРеквизиты.Добавить(Новый РеквизитФормы("ТЗ"+Стр.ВидЦены+"_Процент", Новый ОписаниеТипов("Число",КвалификаторыЧисла), "ТЗ", "ТЗ"+Стр.ВидЦены+"_Процент", Истина));
		
		Попытка
			ИзменитьРеквизиты(нРеквизиты);
		Исключение
			//Значит уже есть такие реквизиты
		КонецПопытки;
		
		
		Попытка
			//Добавление колонки ВидЦены  ЭтоГруппа и у нее данных нет Только отображение в шапке
			нЭлемент1								= Элементы.Добавить("ТЗ_"+Стр.ВидЦены, Тип("ГруппаФормы"), Элементы.ТЗ);
			нЭлемент1.Вид 							= ВидГруппыФормы.ГруппаКолонок;     
			нЭлемент1.Заголовок 					= ""+Стр.ВидЦены;
			нЭлемент1.ОтображатьВШапке 				= Истина;
			нЭлемент1.Группировка 	    			= ГруппировкаКолонок.Горизонтальная;
			нЭлемент1.ГоризонтальноеПоложениеВШапке = ГоризонтальноеПоложениеЭлемента.Центр;
			нЭлемент1.ШрифтЗаголовка = Новый Шрифт(,,Истина);
			
			//Добавление колонки Цена
			нЭлемент2 			  = Элементы.Добавить("ТЗ_"+Стр.ВидЦены+"_Цена", Тип("ПолеФормы"), нЭлемент1); 
			нЭлемент2.Вид 		  = ВидПоляФормы.ПолеВвода; 
			нЭлемент2.ПутьКДанным = "ТЗ.ТЗ"+Стр.ВидЦены+"_Цена";
			нЭлемент2.Заголовок	  = "Старая цена";
			нЭлемент2.ГоризонтальноеПоложениеВШапке = ГоризонтальноеПоложениеЭлемента.Центр;
			нЭлемент2.Ширина 	  = 7;
			нЭлемент2.ТолькоПросмотр = Истина;
			
			//Добавление колонки Процент
			нЭлемент4 			  = Элементы.Добавить("ТЗ_"+Стр.ВидЦены+"_Процент", Тип("ПолеФормы"), нЭлемент1); 
			нЭлемент4.Вид 		  = ВидПоляФормы.ПолеВвода; 
			нЭлемент4.ПутьКДанным = "ТЗ.ТЗ"+Стр.ВидЦены+"_Процент";
			нЭлемент4.Заголовок   = "наценка %";
			нЭлемент4.ГоризонтальноеПоложениеВШапке = ГоризонтальноеПоложениеЭлемента.Центр;
			нЭлемент4.УстановитьДействие("ПриИзменении","ПриИзмененииКолонкиТабличногоПоля");
			нЭлемент4.Ширина = 7;
			нЭлемент4.Шрифт  = Новый Шрифт(,,Истина);
			
			//Добавление колонки НоваяЦена
			нЭлемент3 = Элементы.Добавить("ТЗ_"+Стр.ВидЦены+"_НоваяЦена", Тип("ПолеФормы"), нЭлемент1); 
			нЭлемент3.Вид 			= ВидПоляФормы.ПолеВвода; 
			нЭлемент3.ПутьКДанным 	= "ТЗ.ТЗ"+Стр.ВидЦены+"_НоваяЦена";
			нЭлемент3.Заголовок 	= "Новая цена";
			нЭлемент3.ГоризонтальноеПоложениеВШапке = ГоризонтальноеПоложениеЭлемента.Центр;
			нЭлемент3.УстановитьДействие("ПриИзменении","ПриИзмененииКолонкиТабличногоПоля");
			нЭлемент3.Ширина = 7;
			нЭлемент3.Шрифт  = Новый Шрифт(,,Истина);
			
			Если Сч%2=0 Тогда 
				нЭлемент2.ЦветФона	  = WebЦвета.Бежевый;   
				нЭлемент3.ЦветФона	  = WebЦвета.Бежевый;
				нЭлемент4.ЦветФона	  = WebЦвета.Бежевый; 
			КонецЕсли;
			
		Исключение
			Сообщить(ОписаниеОшибки());
			//Если колонки были созданы ранее
		КонецПопытки;		
		
	КонецЦикла; 	
	
КонецПроцедуры



//УСТАНОВКА ЦЕН
&НаКлиенте
Процедура РассчитатьЦены(Команда)
	
	Отказ = Ложь;
	ОчиститьСообщения();
	
	Если БулевоПоФормуле и Не ЗначениеЗаполнено(ВидЦены1) 
		или БулевоПоФормуле и Не ЗначениеЗаполнено(ВидЦены2) Тогда 
		//или БулевоПоФормуле и Не ЗначениеЗаполнено(Знак)
		//или БулевоПоФормуле и Число = 0
		//или БулевоПоФормуле и Не ЗначениеЗаполнено(СуммаИлиПроцент) Тогда
		Сообщить("Не верно указана формула расчета цены!");
		Отказ = Истина;
	КонецЕсли;
	
	//Если БулевоОкругление и Не ЗначениеЗаполнено(ВидЦены3) 
	//	или БулевоОкругление и Не ЗначениеЗаполнено(Округление) Тогда 
	//	Сообщить("Не заполнено округление!");
	//	Отказ = Истина;
	//КонецЕсли;
	
	Если ТЗ.Количество() = 0 Тогда 
		Сообщить("Невозможна установка цен! Таблица товаров пустая.");
		Отказ = Истина;
	КонецЕсли;
	
	Если НЕ Отказ Тогда		
		РассчитатьЦеныНаСервере();
		//СформироватьСписокНаСервере();
	КонецЕсли;
	
КонецПроцедуры
&НаКлиенте
Процедура РассчитатьЦеныНаСервере()
	
	Для Каждого Стр Из ТЗ Цикл
		
		Если НЕ Стр.Выбран Тогда
			Продолжить;
		КонецЕсли;
		
		Если БулевоПоФормуле Тогда
			
			РассчетнаяЦена = 0;
			ЦенаНаценки	   = Стр["ТЗ"+ВидЦены2+"_Цена"];
			
			Если СуммаИлиПроцент = "+" Тогда
				
				Если ЗНАК = "+" Тогда
					РассчетнаяЦена = ЦенаНаценки + Число;
				ИначеЕсли ЗНАК = "-" Тогда
					РассчетнаяЦена = ЦенаНаценки - Число;
				ИначеЕсли ЗНАК = "/" Тогда
					РассчетнаяЦена = ЦенаНаценки / Число;
				ИначеЕсли ЗНАК = "*" Тогда
					РассчетнаяЦена = ЦенаНаценки * Число;				
				КонецЕсли;
			Иначе
				Если ЗНАК = "+" Тогда
					РассчетнаяЦена = ЦенаНаценки + (ЦенаНаценки/100 * Число);
				ИначеЕсли ЗНАК = "-" Тогда
					РассчетнаяЦена = ЦенаНаценки - (ЦенаНаценки/100 * Число);
				ИначеЕсли ЗНАК = "/" Тогда
					РассчетнаяЦена = ЦенаНаценки / (ЦенаНаценки/100 * Число);
				ИначеЕсли ЗНАК = "*" Тогда
					РассчетнаяЦена = ЦенаНаценки * (ЦенаНаценки/100 * Число);				
				КонецЕсли;
			КонецЕсли;
			
			Стр["ТЗ"+ВидЦены1+"_НоваяЦена"] = РассчетнаяЦена;
			
			Если ЗначениеЗаполнено(ЦенаНаценки) Тогда
				Стр["ТЗ"+ВидЦены1+"_Процент"] 	= (РассчетнаяЦена - ЦенаНаценки) / (ЦенаНаценки / 100);
			КонецЕсли;
			
		Иначе                   
			//Вручную			
		КонецЕсли;
		
		Если БулевоОкругление и ВидЦены3 = ВидЦены1 Тогда			
			Стр["ТЗ"+ВидЦены1+"_НоваяЦена"] = Округлить(Стр["ТЗ"+ВидЦены1+"_НоваяЦена"]);
		КонецЕсли;
		
	КонецЦикла;
	
КонецПроцедуры




&НаКлиенте
Процедура ВыбратьВсеВидыЦен(Команда)	
	Для Каждого Стр из ВидыЦен Цикл
		Стр.Выбран = Истина;
	КонецЦикла;	
КонецПроцедуры
&НаКлиенте
Процедура ОтменитьВыборВсеВидыЦен(Команда) 	
	Для Каждого Стр из ВидыЦен Цикл
		Стр.Выбран = Ложь;
	КонецЦикла;	
КонецПроцедуры
&НаКлиенте
Процедура ВыбратьВсе(Команда)
	Для Каждого Стр из ТЗ Цикл
		Стр.Выбран = Истина;
	КонецЦикла;	
КонецПроцедуры
&НаКлиенте
Процедура ОтменаВыбратьВсе(Команда)
	Для Каждого Стр из ТЗ Цикл
		Стр.Выбран = Ложь;
	КонецЦикла;
КонецПроцедуры


&НаКлиенте
Процедура БулевоПоДокументуПриИзменении(Элемент)
	
	Если БулевоПоДокументу Тогда
		БулевоПоНоменклатуре = Ложь;
		Элементы.Документ.Доступность = Истина;
		Элементы.Номенклатура.Доступность = Ложь;
	Иначе
		Элементы.Документ.Доступность = Ложь;
	КонецЕсли;
	
КонецПроцедуры
&НаКлиенте
Процедура БулевоПоНоменклатуреПриИзменении(Элемент)
	Если БулевоПоНоменклатуре Тогда
		БулевоПоДокументу = Ложь;
		Элементы.Документ.Доступность = Ложь;
		Элементы.Номенклатура.Доступность = Истина;
	Иначе
		Элементы.Номенклатура.Доступность = Ложь;
	КонецЕсли;
	
КонецПроцедуры
&НаКлиенте
Процедура ДатаЦенПриИзменении(Элемент)
	ТЗ.Очистить();
КонецПроцедуры
&НаКлиенте
Процедура БулевоПоФормулеПриИзменении(Элемент)
	
	Если БулевоПоФормуле Тогда
		Элементы.ВидЦены1.Доступность 	= Истина;
		Элементы.ВидЦены2.Доступность 	= Истина;
		Элементы.Знак.Доступность 		= Истина;
		Элементы.Число.Доступность 		= Истина;
		Элементы.СуммаИлиПроцент.Доступность = Истина;
	Иначе 		
		Элементы.ВидЦены1.Доступность 	= Ложь;
		Элементы.ВидЦены2.Доступность 	= Ложь;
		Элементы.Знак.Доступность 		= Ложь;
		Элементы.Число.Доступность 		= Ложь;
		Элементы.СуммаИлиПроцент.Доступность = Ложь;
	КонецЕсли;
	
КонецПроцедуры
&НаКлиенте
Процедура БулевоОкруглениеПриИзменении(Элемент)
	Если БулевоОкругление Тогда
		Элементы.ВидЦены3.Доступность 	= Истина;
		Элементы.Округление.Доступность = Истина;
	Иначе 		
		Элементы.ВидЦены3.Доступность 	= Ложь;
		Элементы.Округление.Доступность = Ложь;
	КонецЕсли;
	
КонецПроцедуры








&НаСервере
Процедура ЗафиксироватьЦеныНаСервере()
	
	Для каждого Стр из ТЗ Цикл
		
		Если НЕ Стр.Выбран Тогда
			Продолжить;
		КонецЕсли;
		
		Для Каждого СтрВидыЦен из ВидыЦен Цикл
			
			Если НЕ СтрВидыЦен.Выбран Тогда
				Продолжить;
			КонецЕсли;
			
			ВидЦеныСтрокой = Строка(СтрВидыЦен.ВидЦены);
			
			Если ЗначениеЗаполнено(Стр["ТЗ"+ВидЦеныСтрокой+"_НоваяЦена"]) Тогда				
				НоваяЗапись = РегистрыСведений.ЦеныНоменклатуры.СоздатьМенеджерЗаписи();
				НоваяЗапись.Период 			= ДатаЦен;
				НоваяЗапись.ВидЦены			= СтрВидыЦен.ВидЦены;
				НоваяЗапись.Номенклатура	= Стр.Номенклатура;
				НоваяЗапись.Цена			= Стр["ТЗ"+ВидЦеныСтрокой+"_НоваяЦена"];
				НоваяЗапись.Записать(); 
			КонецЕсли; 			
		КонецЦикла;		
	КонецЦикла;
	
КонецПроцедуры
&НаКлиенте
Процедура ЗафиксироватьЦены(Команда)	
	Оповещение = Новый ОписаниеОповещения("ЗафиксироватьЦеныВопросЗавершение", ЭтотОбъект); 
	ТекстВопроса = "Зафиксировать цены?"; 
	ПоказатьВопрос(Оповещение, ТекстВопроса, РежимДиалогаВопрос.ДаНет);	 
КонецПроцедуры
&НаКлиенте 
Процедура ЗафиксироватьЦеныВопросЗавершение(Результат, ДополнительныеПараметры) Экспорт 
	Если Результат = КодВозвратаДиалога.Да Тогда
		ЗафиксироватьЦеныНаСервере();
		СформироватьСписокНаСервере();
		
		Сообщить("Цены успешно зафиксированы!");  
	Иначе	
		Возврат;   
	КонецЕсли;
КонецПроцедуры





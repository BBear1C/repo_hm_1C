﻿//////////////////////////////////////////////////////////////////////////////// 
// ПРОЦЕДУРЫ И ФУНКЦИИ
//

// Посчитать сумму по всем товарам в документе
Функция СуммаПоТоварамВДокументе()
	СуммаПоТоварам = 0;
	Для каждого Товар из Товары Цикл
		СуммаПоТоварам = СуммаПоТоварам + Товар.Сумма;
	КонецЦикла;
	Возврат СуммаПоТоварам;
КонецФункции

// Формирование печатной формы документа
// 
// Параметры: 
//  Нет. 
// 
// Возвращаемое значение: 
//  ТабличныйДокумент - Сформированный табличный документ.
Процедура ПечатнаяФорма(ТабличныйДокумент) Экспорт
	Макет = Документы.РасходТовара.ПолучитьМакет("МакетПечати");

	// Заголовок
	Область = Макет.ПолучитьОбласть("Заголовок");
	ТабличныйДокумент.Вывести(Область);
	
	// Получаем сумму по всем товарам
	СуммаПоТоварам = СуммаПоТоварамВДокументе();
	
	// Определяем валюту
	ТекущаяВалюта = Валюта;	
	Если ТекущаяВалюта.Пустая() Тогда
		ТекущаяВалюта = Константы.ВалютаУчета.Получить();
	КонецЕсли;
	
	// Формируем параметры валюты
	ПараметрыТекущейВалюты = "";
	Если Не ПустаяСтрока(ТекущаяВалюта.НаименованиеОсновнойВалюты) Тогда
		ПараметрыТекущейВалюты = ПараметрыТекущейВалюты + ТекущаяВалюта.НаименованиеОсновнойВалюты + ",";
	КонецЕсли;
	Если Не ПустаяСтрока(ТекущаяВалюта.НаименованиеРазменнойВалюты) Тогда
		ПараметрыТекущейВалюты = ПараметрыТекущейВалюты + ТекущаяВалюта.НаименованиеРазменнойВалюты + ",";
	КонецЕсли;	
	Если Не ПустаяСтрока(ПараметрыТекущейВалюты) Тогда
		ПараметрыТекущейВалюты = ПараметрыТекущейВалюты + "2";
	КонецЕсли;

	СуммаПоТоварамПрописью = Новый Массив;
	
	ВариантыПростойПрописиСуммыПоТоварам = ПолучитьСклоненияСтрокиПоЧислу(ПараметрыТекущейВалюты, СуммаПоТоварам,,
		"ЧС=Количественное", "ПД=Именительный; ПЧ=Число");
	Если Не ВариантыПростойПрописиСуммыПоТоварам.Количество() = 0 Тогда                                             
		ПолужирныйШрифт = Новый Шрифт(Макет.Область("СуммаПоТоварам").Шрифт, , , Истина);
		СуммаПоТоварамПрописью.Добавить(Новый ФорматированнаяСтрока(ВариантыПростойПрописиСуммыПоТоварам[0], ПолужирныйШрифт,,));
	КонецЕсли;	
	
	ВариантыСложнойПрописиСуммыПоТоварам = ПолучитьСклоненияСтрокиПоЧислу(ПараметрыТекущейВалюты, СуммаПоТоварам,,
		"ЧС=Количественное", "ПД=Именительный; ПЧ=ЧислоПрописью");
	Если Не ВариантыСложнойПрописиСуммыПоТоварам.Количество() = 0 Тогда
		СуммаПоТоварамПрописью.Добавить(" " + "(" + ВариантыСложнойПрописиСуммыПоТоварам[0] + ")"); 
	КонецЕсли;
	
	// Шапка
	Шапка = Макет.ПолучитьОбласть("Шапка");
	Шапка.Параметры.Заполнить(ЭтотОбъект);
		
	
	Если СуммаПоТоварамПрописью.Количество() > 0 Тогда
		Шапка.Параметры.СуммаПоТоварам = Новый ФорматированнаяСтрока(СуммаПоТоварамПрописью);
	Иначе
		Шапка.Параметры.СуммаПоТоварам = СуммаПоТоварам; 
	КонецЕсли;

	ТабличныйДокумент.Вывести(Шапка);

	// Товары
	Область = Макет.ПолучитьОбласть("ТоварыШапка");
	ТабличныйДокумент.Вывести(Область);
	ОбластьТовары = Макет.ПолучитьОбласть("Товары");

	Для Каждого ТекСтрокаТовары Из Товары Цикл
		ОбластьТовары.Параметры.Заполнить(ТекСтрокаТовары);
		ТабличныйДокумент.Вывести(ОбластьТовары);
	КонецЦикла;
КонецПроцедуры

// Формирование печатной формы документа
// 
// Параметры: 
//  Нет. 
// 
// Возвращаемое значение: 
//  ТабличныйДокумент - Сформированный табличный документ.
Процедура Пересчитать() Экспорт

	Для каждого ТекСтрокаТовары Из Товары Цикл

		ТекСтрокаТовары.Сумма = ТекСтрокаТовары.Количество * ТекСтрокаТовары.Цена;

	КонецЦикла;

КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// ОБРАБОТЧИКИ СОБЫТИЙ ОБЪЕКТА

Процедура ОбработкаПроведения(Отказ, Режим)

	// Формирование движений регистров накопления ТоварныеЗапасы и Продажи.
	Движения.ТоварныеЗапасы.Записывать = Истина;
	Движения.Продажи.Записывать = Истина;
	Если Режим = РежимПроведенияДокумента.Оперативный Тогда
		Движения.ТоварныеЗапасы.БлокироватьДляИзменения = Истина;
	КонецЕсли;	

	// Создадим запрос, чтобы получать информацию об услугах
	Запрос = Новый Запрос("ВЫБРАТЬ
						  |    ТоварыВДокументе.НомерСтроки КАК НомерСтроки
						  |ИЗ
						  |    Документ.РасходТовара.Товары КАК ТоварыВДокументе
						  |ГДЕ
						  |    ТоварыВДокументе.Ссылка = &Ссылка
						  |    И ТоварыВДокументе.Товар.Вид = ЗНАЧЕНИЕ(Перечисление.ВидыТоваров.Услуга)");

	Запрос.УстановитьПараметр("Ссылка", Ссылка);
	РезультатУслуги = Запрос.Выполнить().Выгрузить();
	РезультатУслуги.Индексы.Добавить("НомерСтроки");

	Для каждого ТекСтрокаТовары Из Товары Цикл

		Строка = РезультатУслуги.Найти(ТекСтрокаТовары.НомерСтроки, "НомерСтроки");
		Если Строка = Неопределено Тогда
			
			// Не услуга
			Движение = Движения.ТоварныеЗапасы.Добавить();
			Движение.ВидДвижения = ВидДвиженияНакопления.Расход;
			Движение.Период = Дата;
			Движение.Товар = ТекСтрокаТовары.Товар;
			Движение.Склад = Склад;
			Движение.Количество = ТекСтрокаТовары.Количество;

		КонецЕсли;

		Движение = Движения.Продажи.Добавить();
		Движение.Период = Дата;
		Движение.Товар = ТекСтрокаТовары.Товар;
		Движение.Покупатель = Покупатель;
		Движение.Количество = ТекСтрокаТовары.Количество;
		Движение.Сумма = ТекСтрокаТовары.Сумма;

	КонецЦикла;

	// Формирование движения регистра накопления Взаиморасчеты.
	Движения.Взаиморасчеты.Записывать = Истина;
	Движение = Движения.Взаиморасчеты.Добавить();
	Движение.ВидДвижения = ВидДвиженияНакопления.Расход;
	Движение.Период = Дата;
	Движение.Контрагент = Покупатель;
	Движение.Валюта = Валюта;
	Движение.Договор = Договор;

	Если Валюта.Пустая() Тогда
		Движение.Сумма = Товары.Итог("Сумма");
	Иначе

		Курс = РегистрыСведений.КурсыВалют.ПолучитьПоследнее(Дата, Новый Структура("Валюта", Валюта)).Курс;

		Если Курс = 0 Тогда
			Движение.Сумма = Товары.Итог("Сумма");
		Иначе
			Движение.Сумма = Товары.Итог("Сумма") / Курс;
		КонецЕсли;

	КонецЕсли;

	//Запишем движения
	Движения.Записать();
	
	//Контроль остатков при оперативном проведении
	Если Режим = РежимПроведенияДокумента.Оперативный Тогда
		// Создадим запрос, чтобы контролировать остатки по товарам
		Запрос = Новый Запрос("ВЫБРАТЬ
							  |    ТоварыВДокументе.Товар КАК Товар,
							  |    СУММА(ТоварыВДокументе.Количество) КАК Количество,
							  |    МАКСИМУМ(ТоварыВДокументе.НомерСтроки) КАК НомерСтроки
							  |
							  |ПОМЕСТИТЬ ТребуетсяТовара
							  |
							  |ИЗ
							  |    Документ.РасходТовара.Товары КАК ТоварыВДокументе
							  |
							  |ГДЕ
							  |    ТоварыВДокументе.Ссылка = &Ссылка
							  |    И ТоварыВДокументе.Товар.Вид = ЗНАЧЕНИЕ(Перечисление.ВидыТоваров.Товар)
							  |
							  |СГРУППИРОВАТЬ ПО
							  |    ТоварыВДокументе.Товар
							  |
							  |ИНДЕКСИРОВАТЬ ПО
							  |    Товар
							  |;
							  |
							  |////////////////////////////////////////////////////////////////////////////////
							  |ВЫБРАТЬ
							  |    ПРЕДСТАВЛЕНИЕ(ТребуетсяТовара.Товар) КАК ТоварПредставление,
							  |    ВЫБОР
							  |        КОГДА - ЕСТЬNULL(ТоварныеЗапасыОстатки.КоличествоОстаток, 0) > ТоварыВДокументе.Количество
							  |            ТОГДА ТоварыВДокументе.Количество
							  |        ИНАЧЕ - ЕСТЬNULL(ТоварныеЗапасыОстатки.КоличествоОстаток, 0)
							  |    КОНЕЦ КАК Нехватка,
							  |    ТоварыВДокументе.Количество - ВЫБОР
							  |        КОГДА - ЕСТЬNULL(ТоварныеЗапасыОстатки.КоличествоОстаток, 0) > ТоварыВДокументе.Количество
							  |            ТОГДА ТоварыВДокументе.Количество
							  |        ИНАЧЕ - ЕСТЬNULL(ТоварныеЗапасыОстатки.КоличествоОстаток, 0)
							  |    КОНЕЦ КАК МаксимальноеКоличество,
							  |    ТребуетсяТовара.НомерСтроки КАК НомерСтроки
							  |
							  |ИЗ
							  |    ТребуетсяТовара КАК ТребуетсяТовара
							  |        ЛЕВОЕ СОЕДИНЕНИЕ РегистрНакопления.ТоварныеЗапасы.Остатки(
							  |                ,
							  |                Товар В
							  |                        (ВЫБРАТЬ
							  |                            ТребуетсяТовара.Товар
							  |                        ИЗ
							  |                            ТребуетсяТовара)
							  |                    И Склад = &Склад) КАК ТоварныеЗапасыОстатки
							  |        ПО ТребуетсяТовара.Товар = ТоварныеЗапасыОстатки.Товар
							  |        ЛЕВОЕ СОЕДИНЕНИЕ Документ.РасходТовара.Товары КАК ТоварыВДокументе
							  |        ПО ТребуетсяТовара.Товар = ТоварыВДокументе.Товар
							  |            И ТребуетсяТовара.НомерСтроки = ТоварыВДокументе.НомерСтроки
							  |
							  |ГДЕ
							  |    ТоварыВДокументе.Ссылка = &Ссылка И
							  |    0 > ЕСТЬNULL(ТоварныеЗапасыОстатки.КоличествоОстаток, 0)
							  |
							  |УПОРЯДОЧИТЬ ПО
							  |    НомерСтроки");

		Запрос.УстановитьПараметр("Склад", Склад);
		Запрос.УстановитьПараметр("Ссылка", Ссылка);
		РезультатСНехваткой = Запрос.Выполнить();

		ВыборкаРезультатаСНехваткой = РезультатСНехваткой.Выбрать();

		// Выдадим ошибки для строк, в которых не хватает остатка
		Пока ВыборкаРезультатаСНехваткой.Следующий() Цикл

			Сообщение = Новый СообщениеПользователю();
			Сообщение.Текст = НСтр("ru = 'Не хватает '", "ru") 
				+ ВыборкаРезультатаСНехваткой.Нехватка 
				+ НСтр("ru = ' единиц товара'", "ru") + """" 
				+ ВыборкаРезультатаСНехваткой.ТоварПредставление 
				+ """" 
				+ НСтр("ru = ' на складе'", "ru") 
				+ """" 
				+ Склад 
				+ """." 
				+ НСтр("ru = 'Максимальное количество: '", "ru") 
				+ ВыборкаРезультатаСНехваткой.МаксимальноеКоличество 
				+ ".";
			Сообщение.Поле = НСтр("ru = 'Товары'", "ru") 
				+ "[" 
				+ (ВыборкаРезультатаСНехваткой.НомерСтроки - 1) 
				+ "]." 
				+ НСтр("ru = 'Количество'", "ru");
			Сообщение.УстановитьДанные(ЭтотОбъект);
			Сообщение.Сообщить();
			Отказ = Истина;

		КонецЦикла;

	КонецЕсли;
	
КонецПроцедуры

Процедура ОбработкаПроверкиЗаполнения(Отказ, ПроверяемыеРеквизиты)

	//Удалим из списка проверяемых реквизитов валюту, если по организации не ведется 
	//валютный учет
	Если НЕ ПолучитьФункциональнуюОпцию("ВалютныйУчет", Новый Структура("Организация", Организация)) Тогда
		ПроверяемыеРеквизиты.Удалить(ПроверяемыеРеквизиты.Найти("Валюта"));
	КонецЕсли;	
	
	
	// Проверим заполненность поля "Покупатель"
	Если Покупатель.Пустая() Тогда

		// Если поле Покупатель не заполнено, сообщим об этом пользователю
		Сообщение = Новый СообщениеПользователю();
		Сообщение.Текст = НСтр("ru = 'Не указан Покупатель, для которого выписывается накладная!'", "ru");
		Сообщение.Поле = НСтр("ru = 'Покупатель'", "ru");
		Сообщение.УстановитьДанные(ЭтотОбъект);

		Сообщение.Сообщить();

		// Сообщим платформе, что мы сами обработали проверку заполнения поля "Покупатель"
		ПроверяемыеРеквизиты.Удалить(ПроверяемыеРеквизиты.Найти("Покупатель"));
		// Так как информация в документе не консистентна, то продолжать работу дальше смысла нет
		Отказ = Истина;

	КонецЕсли;

	//Если склад не заполнен, то проверим есть ли в документе что-то кроме услуг
	Если Склад.Пустая() И Товары.Количество() > 0 Тогда

		// Создадим запрос, чтобы получать информацию об товарах
		Запрос = Новый Запрос("ВЫБРАТЬ
							  |    Количество(*) КАК Количество
							  |ИЗ
							  |    Справочник.Товары КАК Товары
							  |ГДЕ
							  |    Товары.Ссылка В (&ТоварыВДокументе)
							  |    И Товары.Вид = ЗНАЧЕНИЕ(Перечисление.ВидыТоваров.Товар)");

		Запрос.УстановитьПараметр("ТоварыВДокументе", Товары.ВыгрузитьКолонку("Товар"));
		Выборка = Запрос.Выполнить().Выбрать();
		Выборка.Следующий();
		Если Выборка.Количество = 0 Тогда
			// Сообщим платформе, что мы сами обработали проверку заполнения поля "Склад"
			ПроверяемыеРеквизиты.Удалить(ПроверяемыеРеквизиты.Найти("Склад"));
		КонецЕсли;

	КонецЕсли;

КонецПроцедуры

Процедура ОбработкаЗаполнения(ДанныеЗаполнения, СтандартнаяОбработка)
	
	Если ТипЗнч(ДанныеЗаполнения) = Тип("ДокументСсылка.Заказ") Тогда
		Организация = ДанныеЗаполнения.Организация;
		Склад = ДанныеЗаполнения.Склад;
		Покупатель = ДанныеЗаполнения.Покупатель;
		Валюта = ДанныеЗаполнения.Валюта;
		ВидЦен = ДанныеЗаполнения.ВидЦен;
		
		Для каждого ТоварОснование Из ДанныеЗаполнения.Товары цикл
	        Товар = Товары.Добавить();
	        ЗаполнитьЗначенияСвойств(Товар, ТоварОснование);		
	    КонецЦикла;
	ИначеЕсли ТипЗнч(ДанныеЗаполнения) = Тип("СправочникСсылка.Контрагенты") Тогда

		ЗапросПоКонтрагенту = Новый Запрос("ВЫБРАТЬ
		                                   |	Контрагенты.ЭтоГруппа,
		                                   |	Контрагенты.ВидЦен
		                                   |ИЗ
		                                   |	Справочник.Контрагенты КАК Контрагенты
		                                   |ГДЕ
		                                   |	Контрагенты.Ссылка = &КонтрагентСсылка");
		ЗапросПоКонтрагенту.УстановитьПараметр("КонтрагентСсылка", ДанныеЗаполнения);
		Выборка = ЗапросПоКонтрагенту.Выполнить().Выбрать();
		Если Выборка.Следующий() И Выборка.ЭтоГруппа Тогда
			Возврат;
		КонецЕсли;
		
		ВидЦен     = Выборка.ВидЦен;
		Покупатель = ДанныеЗаполнения.Ссылка;

	ИначеЕсли ТипЗнч(ДанныеЗаполнения) = Тип("Структура") Тогда

		Значение = Неопределено;

		Если ДанныеЗаполнения.Свойство("Покупатель", Значение) Тогда
			ВидЦен = Значение.ВидЦен;
		КонецЕсли;

	КонецЕсли;

КонецПроцедуры


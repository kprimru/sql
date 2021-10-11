IF Object_Id('dbo.ClientTypeRules', 'U') IS NULL BEGIN
    CREATE TABLE dbo.ClientTypeRules
    (
        [System_Id]     SmallInt    NOT NULL,
        [DistrType_Id]  SmallInt    NOT NULL,
        [ClientType_Id] SmallInt    NOT NULL,
        CONSTRAINT [PK_dbo.ClientTypeRules] PRIMARY KEY CLUSTERED ([System_Id], [DistrType_Id])
    );
    
   -- + создание FK
END;
GO
-- заполняем таблицу правил
INSERT INTO dbo.ClientTypeRules([System_Id], [DistrType_Id], [ClientType_Id])
SELECT S.[SystemID], D.[DistrTypeID], C.[ClientTypeID]
FROM dbo.SystemTable AS S
CROSS JOIN dbo.DistrTypeTable AS D
CROSS APPLY
(
    SELECT
        [Category] = CASE
                    -- тут можно взять CASE из вьюшки dbo.ClientTypeAllView и адаптировать его под таблицы S и D
) AS C 
INNER JOIN dbo.ClientTypeTable AS T ON T.[ClientTypeName] = C.[Category]
WHERE NOT EXISTS
    (
        SELECT *
        FROM dbo.ClientTypeRules AS R
        WHERE R.[System_Id] = S.[SystemID]
            AND R.[DistrType_Id] = D.[DistrTypeID]
    )
GO
CREATE VIEW dbo.ClientTypeRulesView AS
-- тут вьюшка по новым правилам, через таблицу dbo.ClientTypeRules
GO
--проверить, что она правильно работает, это не должно ничего выдавать. Проверь)

SELECT *
FROM dbo.ClientTypeRulesView

EXCEPT 

SELECT *
FROM dbo.ClientTypeAllView

SELECT *
FROM dbo.ClientTypeAllView

EXCEPT 

SELECT *
FROM dbo.ClientTypeRulesView
GO
--Если все ок - в процедуре dbo.CLIENT_TYPE_RECALCULATE переходим на новую вьюху ClientTypeRulesView

--Все. Готово.

--А нет! не готово, потому что надо еще уметь правила настраивать

--1. Создаем процедуры
--[dbo].[ClientTypeRules@Select]
--[dbo].[ClientTypeRule@Get]
--[dbo].[ClientTypeRule@Save] - для сохранения правила. В идеале - надо сохранять правила массово, сразу для нескольких систем .Но отложим на потом. Так что пока по одному правилу работаем
--[dbo].[ClientTypeRule@Recalculate Clients] - пересчитать категорию по всем клиентам
--2. Создаем триггеры на dbo.SystemTable и dbo.DistrTypeTable, которые будут заполнять таблицу dbo.ClientTypeRules
--3. Создаем справочник в Delphi и карточку для редактирования правила.

--PROFIT!
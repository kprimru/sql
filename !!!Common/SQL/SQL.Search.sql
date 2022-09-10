/****** Object:  StoredProcedure [SQL].[Search]    Script Date: 11.09.2022 0:55:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE OR ALTER PROCEDURE [SQL].[Search]
    @String VarChar(256)
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT
        [Object_Name]   = '[' + S.[name] + '].[' + O.[name] + ']',
        [Line]          = LTrim(RTrim(Replace(Replace(L.[Line], Char(13), ''), Char(9), '')))
    FROM [sys].[objects]        AS O
    INNER JOIN [sys].[schemas]  AS S ON O.[schema_Id] = S.[schema_id]
    CROSS APPLY
    (
        SELECT [Line] = Item
        FROM [SQL].[Split](Object_Definition(Object_Id), Char(10))
    ) AS L
    WHERE Object_Definition(Object_Id) LIKE '%' + @String + '%'
        AND L.[Line] LIKE '%' + @String + '%'
    ORDER BY
        S.[name],
        O.[name]
END;
GO
USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [Seminar].[Template@Get]
(
    @Id             UniqueIdentifier,   -- участник семинара
    @TemplateCode   VarChar(100)        -- шаблон
)
RETURNS VarChar(Max)
AS
BEGIN
    DECLARE
        @Template_Id    SmallInt,
        @Type_Id        SmallInt,
        @Template       VarChar(Max);

    /*
    IF @TemplateCode IS NULL
        RaisError('Abstract error: @TemplateCode IS NULL', 16, 1);
    */

    SELECT @Template_Id = [Id]
    FROM [Seminar].[Templates->Types]
    WHERE [Code] = @TemplateCode;

    /*
    IF @Template_Id IS NULL
        RaisError('Abstract error: Ќе найден шаблон по коду "%s"', 16, 1, @TemplateCode);
    */

    SELECT
        @Template = R.[Data]
    FROM [Seminar].[Personal]       AS P
    INNER JOIN [Seminar].[Schedule] AS S ON S.[Id] = P.[ID_SCHEDULE]
    INNER JOIN [Seminar].[Subject]  AS SS ON SS.[Id] = S.[ID_SUBJECT]
    CROSS APPLY
    (
        SELECT TOP (1) T.[Data]
        FROM [Seminar].[Schedules->Types:Templates] AS T
        WHERE T.[Type_Id] = S.[Type_Id]
            AND [Template_Id] = @Template_Id
            AND T.[Data] != ''
        ORDER BY T.[Date] DESC
    ) AS T
    CROSS APPLY
    (
        SELECT
            [Data] =
                    Replace(
                    Replace(
                    Replace(
                    Replace(
                    Replace(
                    Replace(T.[Data]
                    , '{ClientPsedo}', IsNull(P.[PSEDO], ''))
                    , '{SeminarName}', SS.[NAME])
                    , '{SeminarDate}', Convert(VarChar(20), DatePart(Day, S.DATE)) + ' ' + M.ROD + ' ' + Convert(VarChar(20), DatePart(Year, S.DATE)))
                    , '{SeminarTime}', LEFT(Convert(VarChar(100), S.TIME, 108), 5))
                    , '{ConfirmLink}', 'http://86.102.88.244/seminar/?type=confirm&id=' + CONVERT(VARCHAR(64), P.ID))
                    , '{SeminarLink}', IsNull(S.[Link], ''))
        FROM [dbo].[Month] AS M
        WHERE DatePart(Month, S.DATE) = M.NUM
    ) AS R
    WHERE P.[Id] = @Id;

    RETURN @Template;
END
GO

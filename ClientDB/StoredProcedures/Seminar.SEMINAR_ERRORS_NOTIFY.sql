USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Seminar].[SEMINAR_ERRORS_NOTIFY]
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

    DECLARE
			@Text	NVarChar(Max);

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

        SET @Text = '';
        SELECT @Text = @Text +
                '������� "' + J.NAME + '" ' + Convert(VarChar(20), S.Date, 104) + ' �� ����� ������, ���������� ��������� �� ����, ��� ���������� ����� ���������� ������ ��������' + Char(10) + Char(13)
        FROM [Seminar].[Schedule] AS S
        INNER JOIN [Seminar].[Subject] AS J ON S.ID_SUBJECT = J.ID
        WHERE IsNull(Link, '') = ''
            AND DATE > DateAdd(Day, 7, GetDate())
            AND EXISTS
                (
                    SELECT *
                    FROM [Seminar].[Schedules->Types:Templates] AS T
                    WHERE T.[Type_Id] = S.[Type_Id]
                        AND T.[Data] LIKE '%{SeminarLink}%'
                );

		IF @Text != '' BEGIN
			EXEC [Common].[MAIL_SEND]
                @Recipients     = 'denisov@bazis;bateneva@bazis',
                @Subject        = '������ �� �������. ��������������',
                @Body_Format    = 'TEXT',
                @Body           = @Text;
		END;

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO

USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[CLIENT_EMAIL_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[CLIENT_EMAIL_SELECT]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [dbo].[CLIENT_EMAIL_SELECT]
	@CLIENT	INT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

    DECLARE @Emails Table
    (
        EMail       VarChar(256),
        Source      VarChar(100)
    );

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

        INSERT INTO @EMails
        SELECT ML, Source
        FROM
        (
            SELECT ClientEMail AS ML, 'Карточка' AS Source
			FROM dbo.ClientTable
			WHERE ClientID = @CLIENT
				AND STATUS = 1

			UNION ALL

			SELECT DISTINCT CP_EMAIL, 'Сотрудник'
			FROM
				dbo.ClientPersonal
				INNER JOIN dbo.ClientTable ON ClientID = CP_ID_CLIENT
			WHERE CP_ID_CLIENT = @CLIENT
				AND STATUS = 1

			UNION ALL

			SELECT DISTINCT EMAIL, 'Рассылка'
			FROM dbo.ClientDelivery
			WHERE ID_CLIENT = @CLIENT

			UNION ALL

			SELECT DISTINCT EMAIL, 'Запись ДС'
			FROM dbo.ClientDutyTable
			WHERE ClientID = @CLIENT
				AND STATUS = 1

			UNION ALL

			SELECT DISTINCT E.EMail, 'Протокол РЦ'
            FROM dbo.ClientDistrView AS D WITH(NOEXPAND)
            CROSS APPLY
            (
                SELECT [EMail] = LTrim(RTrim(SubString(RPR_OPER, CharIndex('->', RPR_OPER) + 2, Len(RPR_OPER))))
                FROM dbo.RegProtocol AS R
                WHERE R.RPR_OPER LIKE 'Изменен email:%->%'
                    AND R.RPR_ID_HOST = D.HostID
                    AND R.RPR_DISTR = D.DISTR
                    AND R.RPR_COMP = D.COMP
            ) AS E
            WHERE D.ID_CLIENT = @CLIENT
                AND E.[EMail] != 'nov1@consultant.ru'
        ) AS E
        WHERE ISNULL(ML, '') <> ''

        SELECT
            E.EMail,
            Source =
            Reverse(Stuff(Reverse(
                (
                    SELECT Source + ','
                    FROM @Emails AS S
                    WHERE S.Email = E.Email
                    FOR XML PATH('')
                )
            ), 1, 1, ''))
        FROM
        (
		    SELECT DISTINCT EMail
		    FROM @Emails
		) AS E;

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_EMAIL_SELECT] TO rl_client_card;
GRANT EXECUTE ON [dbo].[CLIENT_EMAIL_SELECT] TO rl_client_card_r;
GO

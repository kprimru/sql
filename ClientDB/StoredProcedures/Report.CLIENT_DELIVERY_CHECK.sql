USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Report].[CLIENT_DELIVERY_CHECK]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Report].[CLIENT_DELIVERY_CHECK]  AS SELECT 1')
GO
ALTER PROCEDURE [Report].[CLIENT_DELIVERY_CHECK]
	@INPT NVARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

    DECLARE
        @Delivery_Id    UniqueIdentifier;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

        -- ToDo злостный хардкож
        SET @Delivery_Id = 'BFB6FBE5-886C-E511-B356-0007E92AAFC5'

		SELECT
            [Клиент]        = ClientFullname,
            [Статус]        = ServiceStatusName,
            [Email]         = IsNull(D.[EMAIL], E.[EMAIL]),
            [Проблема]      =   CASE
                                    WHEN D.[EMAIL] IS NULL THEN 'Есть в рассылке, нет в ДК'
                                    WHEN E.[EMAIL] IS NULL THEN 'Есть в ДК, нет в рассылке'
                                    ELSE 'ВНИМАНИЕ! ЭТОГО ТЕКСТА ЗДЕСЬ БЫТЬ НЕ ДОЛЖНО!'
                                END
        FROM
        (
            SELECT ClientFullName, ServiceStatusName, Replace(EMAIL, CHAR(13), '') AS EMAIL
            FROM dbo.ClientDelivery AS CD
            INNER JOIN dbo.ClientView AS C WITH(NOEXPAND) ON C.ClientID = CD.ID_CLIENT
            INNER JOIN dbo.ServiceStatusConnected() AS S ON S.ServiceStatusId = C.ServiceStatusID
            WHERE [ID_DELIVERY] = @Delivery_Id
                AND [FINISH] IS NULL
        ) AS D
        FULL JOIN
        (
            SELECT DISTINCT REPLACE(Item, CHAR(13), '') AS EMAIL
            FROM dbo.GET_STRING_TABLE_FROM_LIST(@INPT, CHAR(10))
        ) AS E ON D.EMAIL = E.EMAIL
        WHERE D.EMAIL IS NULL OR E.EMAIL IS NULL
        ORDER BY 1, 2, 3

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Report].[CLIENT_DELIVERY_CHECK] TO rl_report;
GO

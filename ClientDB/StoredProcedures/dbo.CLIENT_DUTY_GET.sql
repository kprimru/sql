USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[CLIENT_DUTY_GET]
	@ID	INT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		SELECT
			ClientDutyDateTime,
			ClientDutyContact,
			ClientDutySurname, ClientDutyName, ClientDutyPatron,
			ClientDutyPos, ClientDutyPhone,
			DutyID, CallTypeID, ClientDutyQuest, ClientDutyDocs, ClientDutyNPO,
			ClientDutyComplete, ClientDutyComment, ClientDutyUncomplete,
			ClientDutyGive, ClientDutyAnswer,
			ClientDutyClaimDate, ClientDutyClaimNum,
			ClientDutyClaimAnswer, ClientDutyClaimComment, ID_DIRECTION,
			(
				SELECT
					(
						SELECT CONVERT(VARCHAR(20), z.SystemID) AS 'ITEM'
						FROM
							dbo.SystemTable z
							INNER JOIN dbo.ClientDutyIBTable y ON z.SystemID = y.SystemID
							WHERE y.ClientDutyID = a.ClientDutyID
						ORDER BY SystemOrder FOR XML PATH(''), type
					)
				FOR XML PATH('root')
			) AS IB_XML,
			REVERSE(STUFF(REVERSE((
			SELECT Convert(VARCHAR(10), SystemTable.SystemID) + ','
			FROM
				dbo.ClientDutyIBTable INNER JOIN
				dbo.SystemTable ON SystemTable.SystemID = ClientDutyIBTable.SystemID
			WHERE a.ClientDutyID = ClientDutyIBTable.ClientDutyID
			ORDER BY SystemShortName FOR XML PATH('')
		)),1,1,'')) AS CheckedIB, ID_GRANT_TYPE, EMAIL, IsNull(LINK, 0) AS LINK
		FROM dbo.ClientDutyTable a
		WHERE ClientDutyID = @ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_DUTY_GET] TO rl_client_duty_r;
GO

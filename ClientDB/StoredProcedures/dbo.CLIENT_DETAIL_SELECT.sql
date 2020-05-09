USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[CLIENT_DETAIL_SELECT]
	@CLIENTID	INT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	DECLARE @AddressType_Id	UniqueIdentifier;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY
		SET @AddressType_Id = (SELECT TOP (1) AT_ID FROM dbo.AddressType WHERE AT_REQUIRED = 1);

		SELECT
			a.ClientID,
			ClientFullName,
			ClientOfficial,
			ClientINN,
			ClientTypeID,
			ClientServiceID AS ServiceID,
			ClientDayBegin,
			ClientDayEnd,
			DinnerBegin,
			DinnerEnd,
			PayTypeID,
			ClientMainBook, ClientNewspaper,
			StatusID AS ServiceStatusID,
			ClientActivity,
			ClientNote,
			ServiceTypeID,
			ClientShortName,
			OriClient,
			ClientEmail,
			DayID,
			RangeID,
			ServiceStart,
			ServiceTime,
			ClientKind_Id,
			ClientPlace,
			PurchaseTypeID,
			ID_HEAD,
			CASE
				WHEN WCL_ID IS NULL THEN CONVERT(BIT, 0)
				ELSE CONVERT(BIT, 1)
			END AS ClientEdit,
			CONVERT(BIT, CASE
				WHEN EXISTS
					(
						SELECT *
						FROM
							dbo.ClientDistrView z WITH(NOEXPAND)
							INNER JOIN dbo.SystemTable x ON x.HostID = z.HostID
							INNER JOIN dbo.BLACK_LIST_REG y ON z.DISTR = y.DISTR AND z.COMP = y.COMP AND x.SystemID = y.ID_SYS
						WHERE z.ID_CLIENT = a.ClientID AND P_DELETE = 0 AND z.DS_REG = 0
					) THEN 1
				ELSE 0
			END) AS IPLock,
			CA_STR = DisplayText,
			CA_FULL = DisplayTextFull,
			STT_CHECK, HST_CHECK, USR_CHECK, INET_CHECK,
			IsLarge, IsDebtor,
			ClientVisitCountID
		FROM dbo.ClientTable a
		LEFT JOIN dbo.[ClientList@Get?Write]() ON WCL_ID = ClientID
		LEFT JOIN Cache.[Client?Addresses] d ON d.Id = a.ClientID AND Type_Id = @AddressType_Id
		WHERE a.ClientID = @CLIENTID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_DETAIL_SELECT] TO rl_client_card;
GO
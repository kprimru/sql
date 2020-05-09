USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[CLIENT_DELETE]
  @ID	INT
AS
BEGIN
	SET NOCOUNT ON

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		INSERT INTO dbo.ClientTable(
				ID_MASTER, STATUS,
				ClientShortName, ClientFullName, ClientOfficial, ClientINN, ClientServiceID,
				StatusID, RangeID, PayTypeID, ServiceTypeID, ClientKind_Id,
				OriClient, ClientActivity, ClientPlace, ClientNote,
				ClientDayBegin, ClientDayEnd, DinnerBegin, DinnerEnd,
				DayID, ServiceStart, ServiceTime, ClientNewspaper, ClientMainBook,
				ClientEmail, PurchaseTypeID, ClientLast, UPD_USER)
			SELECT
				@ID, 2,
				ClientShortName, ClientFullName, ClientOfficial, ClientINN, ClientServiceID,
				StatusID, RangeID, PayTypeID, ServiceTypeID, ClientKind_Id,
				OriClient, ClientActivity, ClientPlace, ClientNote,
				ClientDayBegin, ClientDayEnd, DinnerBegin, DinnerEnd,
				DayID, ServiceStart, ServiceTime, ClientNewspaper, ClientMainBook,
				ClientEmail, PurchaseTypeID, ClientLast, UPD_USER
			FROM dbo.ClientTable
			WHERE ClientID = @ID

		UPDATE dbo.ClientTable
		SET STATUS		=	3,
			ClientLast	=	GETDATE(),
			UPD_USER	=	ORIGINAL_LOGIN()
		WHERE ClientID = @ID

		UPDATE dbo.ClientDistr
		SET STATUS = 2
		WHERE ID_CLIENT = @ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_DELETE] TO rl_client_d;
GO
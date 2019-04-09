USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CLIENT_DELETE]
  @ID	INT
AS
BEGIN
	SET NOCOUNT ON

	INSERT INTO dbo.ClientTable(
			ID_MASTER, STATUS,
			ClientShortName, ClientFullName, ClientOfficial, ClientINN, ClientServiceID,
			StatusID, RangeID, PayTypeID, ServiceTypeID, ClientContractTypeID, 
			OriClient, ClientActivity, ClientPlace, ClientNote, 
			ClientDayBegin, ClientDayEnd, DinnerBegin, DinnerEnd, 
			DayID, ServiceStart, ServiceTime, ClientNewspaper, ClientMainBook, 
			ClientEmail, PurchaseTypeID, ClientLast, UPD_USER)
		SELECT
			@ID, 2,
			ClientShortName, ClientFullName, ClientOfficial, ClientINN, ClientServiceID,
			StatusID, RangeID, PayTypeID, ServiceTypeID, ClientContractTypeID, 
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
END
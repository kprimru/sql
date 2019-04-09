USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CLIENT_DETAIL_SELECT]
	@CLIENTID	INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		a.ClientID, 
		ClientFullName,
		ClientOfficial,
		ClientINN, 
		c.ClientTypeID,		
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
		ClientContractTypeID,
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
		CA_STR,
		CA_FULL,
		STT_CHECK, HST_CHECK, USR_CHECK, INET_CHECK,
		IsLarge, IsDebtor,
		ClientVisitCountID
	FROM
		dbo.ClientTable a
		LEFT OUTER JOIN dbo.ClientWriteList() ON WCL_ID = ClientID
		LEFT OUTER JOIN dbo.ClientTypeAllView b ON a.ClientID = b.ClientID
		LEFT OUTER JOIN dbo.ClientTypeTable c ON c.ClientTypeName = b.CATEGORY
		LEFT OUTER JOIN dbo.ClientAddressView d ON d.CA_ID_CLIENT = a.ClientID AND AT_REQUIRED = 1
	WHERE a.ClientID = @CLIENTID
END
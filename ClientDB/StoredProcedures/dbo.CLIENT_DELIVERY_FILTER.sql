USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CLIENT_DELIVERY_FILTER]
	@DELIVERY	UNIQUEIDENTIFIER,
	@CLIENT		NVARCHAR(256),
	@EMAIL		NVARCHAR(256),
	@CL_STATUS	NVARCHAR(MAX),
	@DL_STATUS	INT,
	@BEGIN		SMALLDATETIME = NULL,
	@SERVICE	INT = NULL
AS
BEGIN
	SET NOCOUNT ON;

	SELECT a.ID, b.ClientID, b.ClientFullName, b.ServiceName, b.ManagerName, b.ServiceStatusIndex, a.EMAIL, a.START, a.FINISH, a.NOTE
	FROM 
		dbo.ClientDelivery a
		INNER JOIN dbo.ClientView b WITH(NOEXPAND) ON a.ID_CLIENT = b.ClientID
	WHERE (a.ID_DELIVERY = @DELIVERY OR @DELIVERY IS NULL)
		AND (b.ClientFullName LIKE @CLIENT OR @CLIENT IS NULL)
		AND (a.EMAIL LIKE @EMAIL OR @EMAIL IS NULL)
		AND (b.ServiceStatusID IN (SELECT ID FROM TableIDFromXML(@CL_STATUS)) OR @CL_STATUS IS NULL)
		AND (@DL_STATUS IS NULL OR @DL_STATUS = 0 OR @DL_STATUS = 1 AND a.FINISH IS NULL OR @DL_STATUS = 2 AND a.FINISH IS NOT NULL)
		AND (a.START >= @BEGIN OR @BEGIN IS NULL)
		AND (b.ServiceID = @SERVICE OR @SERVICE IS NULL)
	ORDER BY ManagerName, ServiceName, ClientFullName, EMAIL
END

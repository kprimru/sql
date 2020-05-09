USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [dbo].[ClientServiceDate]
(
	@CLIENT	INT,
	@DATE	SMALLDATETIME
)
RETURNS INT
AS
BEGIN
	DECLARE @RES INT

	SELECT @RES =
		(
			SELECT TOP 1 ServiceID
			FROM
				(
					SELECT ServiceID, ServiceName, DATE
					FROM
						dbo.ClientService a
						INNER JOIN dbo.ServiceTable c ON a.ID_SERVICE = c.ServiceID
					WHERE ID_CLIENT = @CLIENT
				) AS o_O
			WHERE DATE <= @DATE
			ORDER BY DATE DESC
		)

	RETURN @RES
END
GO

USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CLIENT_ZVE_GET]
	@CLIENT	INT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @ZVE NVARCHAR(MAX)
	
	SET @ZVE = N''
	
	SELECT @ZVE = @ZVE + DistrStr + ', '
	FROM
		(
			SELECT DISTINCT b.DistrStr, SystemOrder, DISTR, COMP
			FROM 
				dbo.RegNodeMainSystemView a WITH(NOEXPAND)
				INNER JOIN dbo.ClientDistrView b ON a.MainHostID = b.HostID AND a.MainDistrNumber = b.DISTR AND a.MainCompNumber = b.COMP
				INNER JOIN Din.NetType d ON d.NT_ID_MASTER = b.DistrTypeId
			WHERE b.ID_CLIENT = @CLIENT
				AND NOT EXISTS
					(
						SELECT *
						FROM dbo.ExpDistr z
						WHERE z.ID_HOST = b.HostID AND z.DISTR = b.DISTR AND z.COMP = b.COMP
					)
				AND d.NT_TECH IN (0, 1)
		) AS o_O
	ORDER BY SystemOrder, DISTR, COMP --FOR XML PATH('')
	
	IF @ZVE <> ''
		SET @ZVE = 'Не подключены к ЗВЭ: ' + REVERSE(STUFF(REVERSE(@ZVE), 1, 2, ''))
		
	SELECT @ZVE AS ZVE
END

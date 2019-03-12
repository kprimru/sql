USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [dbo].[CLIENT_DISCOUNT_WARNING]
AS
BEGIN
	SET NOCOUNT ON;

	SELECT Comment, DistrStr, SST_SHORT, NT_SHORT, EXPIRE_DATE
	FROM
		(
			SELECT DistrStr, SST_SHORT, NT_SHORT, Comment, SystemOrder, DATE, EXPIRE_DATE, DATEDIFF(DAY, GETDATE(), EXPIRE_DATE) AS EXIST
			FROM
				(
					SELECT DistrStr, SST_SHORT, NT_SHORT, Comment, DATE, SystemOrder, DATEADD(MONTH, ADD_MONTH, DATE) AS EXPIRE_DATE
					FROM
						(
							SELECT 
								DistrStr, SST_SHORT, NT_SHORT, Comment, SystemOrder, MIN(b.DATE) AS DATE,
								CASE SST_SHORT
									WHEN 'Ñ.À' THEN 18
									ELSE 24
								END AS ADD_MONTH
							FROM 
								Reg.RegNodeSearchView a WITH(NOEXPAND)
								INNER JOIN Reg.RegProtocolConnectView b WITH(NOEXPAND) ON a.HostID = b.RPR_ID_HOST AND a.DistrNumber = b.RPR_DISTR AND a.CompNumber = b.RPR_COMP
							WHERE /*DS_REG = 0
								AND */SST_SHORT IN ('Ñ.À', 'Ñ.Ê2', 'Ñ.Ê1')
							GROUP BY DistrStr, SST_SHORT, NT_SHORT, Comment, SystemOrder
						) AS o_O
				) AS o_O
		) AS o_O
	WHERE EXIST <= 60
	ORDER BY EXIST, Comment, SystemOrder, DistrStr
END

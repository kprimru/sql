USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Report].[DISCOUNT_SA_SK]
	@PARAM	NVARCHAR(MAX) = NULL
AS
BEGIN
	SET NOCOUNT ON;

    SELECT DistrStr AS [�����������], SST_SHORT AS [��� �������], NT_SHORT AS [��� ����], Comment AS [������], DATE AS [���� �����������], EXPIRE_DATE AS [���� ��������� ������], EXIST AS [�������� ����]--, DISCOUNT AS[������ ������]
	FROM
		(
			SELECT DistrStr, SST_SHORT, NT_SHORT, Comment, SystemOrder, DATE, EXPIRE_DATE, DATEDIFF(DAY, GETDATE(), EXPIRE_DATE) AS EXIST--, DISCOUNT
			FROM
				(
					SELECT DistrStr, SST_SHORT, NT_SHORT, Comment, DATE, SystemOrder, DATEADD(MONTH, ADD_MONTH, DATE) AS EXPIRE_DATE--, DF_DISCOUNT AS DISCOUNT
					FROM
						(
							SELECT 
								DistrStr, SST_SHORT, NT_SHORT, Comment, SystemOrder, MIN(b.DATE) AS DATE, ---DF_DISCOUNT,
								CASE SST_SHORT
									WHEN '�.�' THEN 18
									ELSE 24
								END AS ADD_MONTH
							FROM 
								Reg.RegNodeSearchView a WITH(NOEXPAND)
								INNER JOIN Reg.RegProtocolConnectView b WITH(NOEXPAND) ON a.HostID = b.RPR_ID_HOST AND a.DistrNumber = b.RPR_DISTR AND a.CompNumber = b.RPR_COMP
								--INNER JOIN dbo.DBFDistrFinancingView DFV ON a.DistrNumber = DFV.DIS_NUM AND a.CompNumber = DFV.DIS_COMP_NUM
							WHERE /*DS_REG = 0
								AND */SST_SHORT IN ('�.�', '�.�2', '�.�1'/*, '�.�'*/)
							GROUP BY DistrStr, SST_SHORT, NT_SHORT, Comment, SystemOrder--, DF_DISCOUNT
						) AS o_O
				) AS o_O
		) AS o_O
	ORDER BY EXIST, Comment, SystemOrder, DistrStr
END
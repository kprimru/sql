USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER VIEW [dbo].[AuditReferenceView]
AS
	SELECT 
		'���������� �������� ����������' AS REF_NAME, 
		'����������� ������������' AS REF_ERROR
	WHERE NOT EXISTS
		(
			SELECT *
			FROM dbo.ReportPositionTable
			WHERE RP_PSEDO = 'LEAD'
		)

	UNION ALL

	SELECT 
		'���������� �������� ����������', 
		'����������� ������� ���������'
	WHERE NOT EXISTS
		(
			SELECT *
			FROM dbo.ReportPositionTable
			WHERE RP_PSEDO = 'BUH'
		)

	UNION ALL

	SELECT 
		'���������� �������� ����������', 
		'����������� �������������'
	WHERE NOT EXISTS
		(
			SELECT *
			FROM dbo.ReportPositionTable
			WHERE RP_PSEDO = 'RES'
		)

	UNION ALL

	SELECT 
		'���������� �������� ����������', 
		'����������� 4-� ���������'
	WHERE NOT EXISTS
		(
			SELECT *
			FROM dbo.ReportPositionTable
			WHERE RP_PSEDO = 'PER4'
		)

	UNION ALL

	SELECT 
		'���������� �������� ����������', 
		'����������� 5-� ���������'
	WHERE NOT EXISTS
		(
			SELECT *
			FROM dbo.ReportPositionTable
			WHERE RP_PSEDO = 'PER5'
		)

	UNION ALL

	SELECT 
		'���������� ������� �������', 
		'����������� ���������� ������� ������� "' + CONVERT(VARCHAR, SNC_NET_COUNT) + '" � �����������'
	FROM 
		(
			SELECT DISTINCT SNC_NET_COUNT
			FROM dbo.SystemNetCountTable
			WHERE NOT EXISTS
				(
					SELECT * 
					FROM dbo.RegNodeTable
					WHERE RN_NET_COUNT = SNC_NET_COUNT
				) AND NOT EXISTS
				(
					SELECT *
					FROM dbo.PeriodRegTable
					WHERE REG_ID_NET = SNC_ID
				)
		) AS O_O

	UNION ALL

	SELECT 
		'������', 
		'�������� ���� ������/��������� ������� "' + PR_NAME + '"' AS ER_MSG
	FROM dbo.PeriodTable 
	WHERE 
		(PR_END_DATE <> DATEADD(MONTH, 1, DATEADD(DAY, 1 - DAY(PR_DATE), PR_DATE)) - 1) 
		OR (PR_DATE <> DATEADD(DAY, 1 - DAY(PR_END_DATE), PR_END_DATE))

	UNION ALL

	SELECT 
		'������', 
		'�������� ������ "' + CONVERT(VARCHAR, DATEADD(MONTH, 1, a.PR_DATE), 104) + '"' AS ER_MSG
	FROM PeriodTable a
	WHERE NOT EXISTS
		(
			SELECT * 
			FROM dbo.PeriodTable b
			WHERE a.PR_DATE = DATEADD(MONTH, -1, b.PR_DATE)
		) AND 
		PR_DATE <>
			(
				SELECT MAX(PR_DATE)
				FROM dbo.PeriodTable
			)

	UNION ALL

	SELECT 
		'������', 
		'����������� ������� �� ��������� 6 �������' AS ER_MSG 
	WHERE NOT EXISTS
		(
			SELECT * 
			FROM dbo.PeriodTable
			WHERE PR_DATE >= DATEADD(MONTH, 6,
				(
					SELECT PR_DATE
					FROM dbo.PeriodTable
					WHERE PR_DATE < GETDATE() 
						AND DATEADD(DAY, 1, PR_END_DATE) > GETDATE()
				))
		)

	UNION ALL

	SELECT 
		'��������', 
		'����������� ������� "' + RN_COMMENT + '"'      
	FROM 
		(
			SELECT DISTINCT dbo.GET_HOST_BY_COMMENT(RN_COMMENT) AS RN_COMMENT
			FROM dbo.RegNodeTable
			WHERE NOT EXISTS	
				(
					SELECT * 
					FROM dbo.SubhostTable
					WHERE SH_LST_NAME = dbo.GET_HOST_BY_COMMENT(RN_COMMENT)
				)  
		) AS dt 

	UNION ALL

	SELECT 
		'�����������', 
		'������� "' + SYS_SHORT_NAME + '" ����������� � ������������' AS ER_MSG
	FROM dbo.SystemTable a
	WHERE SYS_ACTIVE = 1 
		AND NOT EXISTS
			(
				SELECT *
				FROM dbo.PriceSystemTable
				WHERE PS_ID_SYSTEM = a.SYS_ID AND
					PS_ID_PERIOD = 
						(
							SELECT PR_ID 
							FROM dbo.PeriodTable 
							WHERE GETDATE() >= PR_DATE AND GETDATE() <  DATEADD(DAY, 1, PR_END_DATE)
						)
			) AND a.SYS_ACTIVE = 1

	UNION ALL

	SELECT 
		'�����������', 
		'����������� ����������� �� ��������� �����' AS ER_MSG
	WHERE NOT EXISTS
		(
			SELECT * 
			FROM dbo.PriceSystemTable
			WHERE PS_ID_TYPE = 1
				AND PS_ID_PERIOD =
				(
					SELECT PR_ID
					FROM dbo.PeriodTable
					WHERE PR_DATE = DATEADD(MONTH, 1,
						(
							SELECT PR_DATE
							FROM dbo.PeriodTable
							WHERE PR_DATE < GETDATE() 
								AND DATEADD(DAY, 1, PR_END_DATE) > GETDATE()
						))
				)
		)

	UNION ALL

	SELECT 
		'�������', 
		'����������� ������� � ����������� "' + SYS_SHORT_NAME + '"'
	FROM 
		(
			SELECT DISTINCT SYS_SHORT_NAME
			FROM dbo.SystemTable
			WHERE SYS_ACTIVE = 1 
				AND NOT EXISTS	
					(
						SELECT * 
						FROM dbo.RegNodeTable
						WHERE SYS_REG_NAME = RN_SYS_NAME
					) 
				AND SYS_REG_NAME <> '-'
				AND NOT EXISTS
					(
						SELECT *
						FROM dbo.PeriodRegTable
						WHERE REG_ID_SYSTEM = SYS_ID
					)
				AND NOT EXISTS
					(
						SELECT *
						FROM dbo.PriceSystemTable
						WHERE PS_ID_SYSTEM = SYS_ID
					)
		) AS dt  		

	UNION ALL

	SELECT 
		'�������', 
		'������� � ������������� ��������� �� "' + SYS_SHORT_NAME + '"�������� � �����'
	FROM dbo.SystemTable
	WHERE SYS_REPORT = 1 
		AND SYS_REG_NAME = '-'

	UNION ALL

	SELECT 
		'������ ������������', 
		'����������� ������ ������������ � ��"' + CONVERT(VARCHAR, RN_SERVICE) + '"'
	FROM 
		(
			SELECT DISTINCT RN_SERVICE
			FROM dbo.RegNodeTable
			WHERE NOT EXISTS	
				(
					SELECT	* 
					FROM	dbo.DistrStatusTable
					WHERE	DS_REG = RN_SERVICE
				)  
		) AS dt      		

	UNION ALL

	SELECT 
		'������ ������������', 
		'����������� ������ ������������ "' + CONVERT(VARCHAR, DS_NAME) + '" � �����������'
	FROM 
		(
			SELECT DISTINCT DS_NAME
			FROM dbo.DistrStatusTable
			WHERE NOT EXISTS	
				(
					SELECT	* 
					FROM	dbo.RegNodeTable
					WHERE	DS_REG = RN_SERVICE
				)  
				AND NOT EXISTS
				(
					SELECT *
					FROM dbo.PeriodRegTable
					WHERE REG_ID_STATUS = DS_ID
				)
		) AS dt      			
	
	UNION ALL

	SELECT 
		'��� �������', 
		'����������� ��� ������� � �� "' + RN_DISTR_TYPE + '"'      
	FROM 
		(
			SELECT DISTINCT RN_DISTR_TYPE
			FROM dbo.RegNodeTable
			WHERE NOT EXISTS	
				(
					SELECT * 
					FROM dbo.SystemTypeTable
					WHERE SST_NAME = RN_DISTR_TYPE
				)  
		) AS dt    

	UNION ALL

	SELECT 
		'��� �������', 
		'����������� ��� ������� "' + SST_CAPTION + '" � �����������'
	FROM 
		(
			SELECT DISTINCT SST_CAPTION
			FROM dbo.SystemTypeTable
			WHERE NOT EXISTS	
				(
					SELECT * 
					FROM dbo.RegNodeTable
					WHERE SST_NAME = RN_DISTR_TYPE
				)  
				AND NOT EXISTS
				(
					SELECT *
					FROM Subhost.RegNodeSubhostTable
					WHERE RNS_ID_TYPE = SST_ID
				)
		) AS dt

	UNION ALL

	SELECT 
		'���������� �����', 
		'��� ����������� ������ �� ������ � ������� "' + CT_NAME + '"'
	FROM 
		(
			SELECT DISTINCT CT_NAME
			FROM dbo.CityTable
			WHERE CT_REGION IS NULL
		) AS dt

	UNION ALL

	SELECT 
		'���.����', 
		ER_MSG
	FROM
		(
			SELECT 
				'����������� ������� "' + RN_SYS_NAME + '". ' + 
				RN_SYS_NAME + ' ' + CONVERT(VARCHAR, RN_DISTR_NUM) AS ER_MSG, 1 AS ER_TYPE
			FROM 
				(
					SELECT DISTINCT RN_SYS_NAME, RN_DISTR_NUM
					FROM dbo.RegNodeTable
					WHERE NOT EXISTS	
						(
							SELECT * 
							FROM dbo.SystemTable
							WHERE SYS_REG_NAME = RN_SYS_NAME
						)             
				) AS dt  
			
			UNION ALL
        
			SELECT 
				'����������� ��� ������� "' + RN_DISTR_TYPE + '". ' + 
				RN_SYS_NAME + ' ' + CONVERT(VARCHAR, RN_DISTR_NUM), 1
			FROM 
				(
					SELECT DISTINCT RN_DISTR_TYPE, RN_SYS_NAME, RN_DISTR_NUM
					FROM dbo.RegNodeTable
					WHERE NOT EXISTS	
						(
							SELECT * 
							FROM dbo.SystemTypeTable
							WHERE SST_NAME = RN_DISTR_TYPE
						)  
				) AS dt    						
		  
			UNION ALL

			SELECT 
				'����������� ������� "' + REG_COMMENT + '". ' + 
				RN_SYS_NAME + ' ' + CONVERT(VARCHAR, RN_DISTR_NUM), 1
			FROM 
				(
					SELECT DISTINCT dbo.GET_HOST_BY_COMMENT(RN_COMMENT) AS REG_COMMENT, RN_SYS_NAME, RN_DISTR_NUM
					FROM dbo.RegNodeTable
					WHERE NOT EXISTS	
						(
							SELECT * 
							FROM dbo.SubhostTable
							WHERE SH_LST_NAME = dbo.GET_HOST_BY_COMMENT(RN_COMMENT)
								AND SH_REG = 1
						)  
				) AS dt      

			UNION ALL

			SELECT 
				'����������� ���������� ������� ������� "' + CONVERT(VARCHAR, RN_NET_COUNT) + '". ' + 
				RN_SYS_NAME + ' ' + CONVERT(VARCHAR, RN_DISTR_NUM), 1
			FROM 
				(
					SELECT DISTINCT RN_NET_COUNT, RN_SYS_NAME, RN_DISTR_NUM
					FROM dbo.RegNodeTable
					WHERE NOT EXISTS	
						(
							SELECT	* 
							FROM	dbo.SystemNetCountTable
							WHERE	SNC_NET_COUNT = RN_NET_COUNT
						)  
				) AS dt      		

			UNION ALL

			SELECT 
				'����������� ������ ������������ "' + CONVERT(VARCHAR,RN_SERVICE) + '". ' + 
				RN_SYS_NAME + ' ' + CONVERT(VARCHAR, RN_DISTR_NUM), 1
			FROM 
				(
					SELECT DISTINCT RN_SERVICE, RN_SYS_NAME, RN_DISTR_NUM
					FROM dbo.RegNodeTable
					WHERE NOT EXISTS	
						(
							SELECT	* 
							FROM	dbo.DistrStatusTable
							WHERE	DS_REG = RN_SERVICE
						)  
				) AS dt      			

			UNION ALL

			SELECT 
				'�������� ������� ��������. '  + 
				RN_SYS_NAME + ' ' + CONVERT(VARCHAR, RN_DISTR_NUM), 2
			FROM
				(
					SELECT DISTINCT
						RN_SYS_NAME, RN_DISTR_NUM
					FROM 
						dbo.RegNodeTable
						INNER JOIN dbo.SubhostTable ON SH_LST_NAME = dbo.GET_HOST_BY_COMMENT(RN_COMMENT)
					WHERE SH_SUBHOST <> RN_SUBHOST AND RN_DISTR_NUM <> 20
				) AS dt
		) AS o_O

USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
�����:		  ������� �������
��������:	  
*/

CREATE PROCEDURE [dbo].[REG_NODE_NOT_FOUND_CLIENT]
AS
BEGIN
	SET NOCOUNT ON

	SELECT 		
		CASE RN_COMP_NUM
			WHEN 1 THEN RN_SYS_NAME + ' ' + CONVERT(VARCHAR, RN_DISTR_NUM)
			ELSE RN_SYS_NAME + ' ' + CONVERT(VARCHAR, RN_DISTR_NUM) + '/' + CONVERT(VARCHAR, RN_COMP_NUM)
		END AS RN_DISTR_NUM, 
		SST_CAPTION, DS_NAME, RN_COMMENT, RN_REG_DATE, RN_COMPLECT
	FROM 
		dbo.RegNodeTable a LEFT OUTER JOIN
		dbo.SystemTypeTable ON SST_NAME = RN_DISTR_TYPE LEFT OUTER JOIN
		dbo.DistrStatusTable ON DS_REG = RN_SERVICE
	WHERE 
		NOT EXISTS 
				(
					SELECT * 
					FROM dbo.DistrView b 
					WHERE 
						DIS_NUM = RN_DISTR_NUM AND 
						DIS_COMP_NUM = RN_COMP_NUM AND 
						SYS_REG_NAME = RN_SYS_NAME AND
						DIS_ACTIVE = 1
				) AND
		RN_DISTR_TYPE NOT IN 
						(
							SELECT 'NCT'
							UNION ALL
							SELECT 'NEK'
							UNION
							SELECT 'HSS'
						)
	ORDER BY RN_SERVICE

	SET NOCOUNT OFF
END








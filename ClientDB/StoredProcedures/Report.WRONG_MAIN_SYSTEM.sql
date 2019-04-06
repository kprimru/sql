USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Report].[WRONG_MAIN_SYSTEM]
	@PARAM	NVARCHAR(MAX) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		DistrStr AS 'Дистрибутив', Comment AS 'Клиент', SST_SHORT AS 'Тип', NT_SHORT AS 'Сеть',
		(
			SELECT TOP 1 b.DistrStr
			FROM Reg.RegNodeSearchView b WITH(NOEXPAND)
			WHERE b.Complect = a.Complect
				AND b.DS_REG = 0
				AND b.DistrStr <> a.DistrStr
			ORDER BY b.SystemOrder
		) AS 'Основная система'
	FROM Reg.RegNodeSearchView a WITH(NOEXPAND)
	WHERE DS_REG = 0
		AND SystemBaseName = 'RBAS020'
		AND SST_SHORT NOT IN ('ДИУ', 'АДМ', 'ДСП')
		AND a.Complect IS NOT NULL
		AND NOT EXISTS
			(
				SELECT *
				FROM Reg.RegNodeSearchView b WITH(NOEXPAND)
				WHERE a.Complect = b.Complect
					AND b.SystemBaseName IN ('BUHL', 'BUHUL',
											'SKBP', 'SKBO', 'SKBB', 
											'SKJE', 'SKJP', 'SKJO', 'SKJB', 
											'SKUE', 'SKUP', 'SKUO', 'SKUB',
											'SBOE', 'SBOP', 'SBOO', 'SBOB',
											'SPK-V', 'SPK-IV', 'SPK-III', 'SPK-II', 'SPK-I',
											'SKBEM', 'SKJEM', 'SKUEM', 'SBOEM')
			)
			
	UNION ALL

	SELECT DistrStr, Comment, SST_SHORT, NT_SHORT,
		(
			SELECT TOP 1 b.DistrStr
			FROM Reg.RegNodeSearchView b WITH(NOEXPAND)
			WHERE b.Complect = a.Complect
				AND b.DS_REG = 0
				AND b.DistrStr <> a.DistrStr
			ORDER BY b.SystemOrder
		)
	FROM Reg.RegNodeSearchView a WITH(NOEXPAND)
	WHERE DS_REG = 0
		AND SystemBaseName = 'EXP'
		AND SST_SHORT NOT IN ('ДИУ', 'АДМ', 'ДСП')
		AND a.Complect IS NOT NULL
		AND NOT EXISTS
			(
				SELECT *
				FROM Reg.RegNodeSearchView b WITH(NOEXPAND)
				WHERE a.Complect = b.Complect
					AND b.SystemBaseName IN ('LAW', 'BVP', 'JURP', 'BUDP')
			)
			
	UNION ALL
			
	SELECT 
		DistrStr AS 'Дистрибутив', Comment AS 'Клиент', SST_SHORT AS 'Тип', NT_SHORT AS 'Сеть',
		(
			SELECT TOP 1 b.DistrStr
			FROM Reg.RegNodeSearchView b WITH(NOEXPAND)
			WHERE b.Complect = a.Complect
				AND b.DS_REG = 0
				AND b.DistrStr <> a.DistrStr
			ORDER BY b.SystemOrder
		) AS 'Основная система'
	FROM Reg.RegNodeSearchView a WITH(NOEXPAND)
	WHERE DS_REG = 0
		AND SystemBaseName IN ('KDG', 'RBAS020')
		AND SST_SHORT NOT IN ('ДИУ', 'АДМ', 'ДСП')
		AND a.Complect IS NOT NULL
		AND EXISTS
			(
				SELECT *
				FROM Reg.RegNodeSearchView b WITH(NOEXPAND)
				WHERE a.Complect = b.Complect
					AND b.SystemBaseName IN (
													'SKBP', 'SKBO', 'SKBB', 
											'SKJE', 'SKJP', 'SKJO', 'SKJB', 
											'SKUE', 'SKUP', 'SKUO', 'SKUB',
											'SBOE', 'SBOP', 'SBOO', 'SBOB',
											'SPK-V', 'SPK-IV', 'SPK-III', 'SPK-II', 'SPK-I',
											'SKBEM', 'SKJEM', 'SKUEM', 'SBOEM')
			)
			
	UNION ALL
			
	SELECT 
		DistrStr AS 'Дистрибутив', Comment AS 'Клиент', SST_SHORT AS 'Тип', NT_SHORT AS 'Сеть',
		(
			SELECT TOP 1 b.DistrStr
			FROM Reg.RegNodeSearchView b WITH(NOEXPAND)
			WHERE b.Complect = a.Complect
				AND b.DS_REG = 0
				AND b.DistrStr <> a.DistrStr
			ORDER BY b.SystemOrder
		) AS 'Основная система'
	FROM Reg.RegNodeSearchView a WITH(NOEXPAND)
	WHERE DS_REG = 0
		AND SystemBaseName IN ('RLAW020')
		AND SST_SHORT NOT IN ('ДИУ', 'АДМ', 'ДСП')
		AND a.Complect IS NOT NULL
		AND EXISTS
			(
				SELECT *
				FROM Reg.RegNodeSearchView b WITH(NOEXPAND)
				WHERE a.Complect = b.Complect
					AND b.SystemBaseName IN (
													'SKBP',
											'SKJE', 'SKJP',
											'SKUE', 'SKUP',
											'SBOE', 'SBOP',
											'SPK-V', 'SPK-IV', 'SPK-III', 'SPK-II', 'SPK-I')
			)
	/*
	UNION ALL
			
	SELECT 
		DistrStr AS 'Дистрибутив', Comment AS 'Клиент', SST_SHORT AS 'Тип', NT_SHORT AS 'Сеть',
		(
			SELECT TOP 1 b.DistrStr
			FROM Reg.RegNodeSearchView b WITH(NOEXPAND)
			WHERE b.Complect = a.Complect
				AND b.DS_REG = 0
				AND b.DistrStr <> a.DistrStr
			ORDER BY b.SystemOrder
		) AS 'Основная система'
	FROM Reg.RegNodeSearchView a WITH(NOEXPAND)
	WHERE DS_REG = 0
		AND SystemBaseName IN ('RBAS020')
		AND SST_SHORT NOT IN ('ДИУ', 'АДМ', 'ДСП')
		AND a.Complect IS NOT NULL
		AND EXISTS
			(
				SELECT *
				FROM Reg.RegNodeSearchView b WITH(NOEXPAND)
				WHERE a.Complect = b.Complect
					AND b.SystemBaseName IN (
													'SKBP', 'SKBO', 'SKBB', 
											'SKJE', 'SKJP', 'SKJO', 'SKJB', 
											'SKUE', 'SKUP', 'SKUO', 'SKUB',
											'SBOE', 'SBOP', 'SBOO', 'SBOB',
											'SPK-V', 'SPK-IV', 'SPK-III', 'SPK-II', 'SPK-I',
											'SKBEM', 'SKJEM', 'SKUEM', 'SBOEM')
			)
	*/
END

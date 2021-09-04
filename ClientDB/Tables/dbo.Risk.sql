USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Risk]
(
        [ID]            UniqueIdentifier      NOT NULL,
        [ID_MASTER]     UniqueIdentifier          NULL,
        [SEARCH_MON]    SmallInt              NOT NULL,
        [SEARCH_CNT]    SmallInt              NOT NULL,
        [DUTY_MON]      SmallInt              NOT NULL,
        [DUTY_CNT]      SmallInt              NOT NULL,
        [RIVAL_MON]     SmallInt              NOT NULL,
        [RIVAL_CNT]     SmallInt              NOT NULL,
        [UPD_WEEK]      SmallInt              NOT NULL,
        [UPD_CNT]       SmallInt              NOT NULL,
        [STUDY_MON]     SmallInt              NOT NULL,
        [STUDY_CNT]     SmallInt              NOT NULL,
        [SEMINAR_MON]   SmallInt              NOT NULL,
        [SEMINAR_CNT]   SmallInt              NOT NULL,
        [STATUS]        TinyInt               NOT NULL,
        [UPD_DATE]      DateTime              NOT NULL,
        [UPD_USER]      NVarChar(256)         NOT NULL,
        CONSTRAINT [PK_dbo.Risk] PRIMARY KEY CLUSTERED ([ID])
);GO

USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ClientStudyClaimPeople]
(
        [ID]         UniqueIdentifier      NOT NULL,
        [ID_CLAIM]   UniqueIdentifier      NOT NULL,
        [SURNAME]    NVarChar(512)         NOT NULL,
        [NAME]       NVarChar(512)         NOT NULL,
        [PATRON]     NVarChar(512)         NOT NULL,
        [POSITION]   NVarChar(512)             NULL,
        [PHONE]      NVarChar(512)             NULL,
        [GR_COUNT]   SmallInt                  NULL,
        [NOTE]       NVarChar(Max)         NOT NULL,
        CONSTRAINT [PK_dbo.ClientStudyClaimPeople] PRIMARY KEY NONCLUSTERED ([ID]),
        CONSTRAINT [FK_dbo.ClientStudyClaimPeople(ID_CLAIM)_dbo.ClientStudyClaim(ID)] FOREIGN KEY  ([ID_CLAIM]) REFERENCES [dbo].[ClientStudyClaim] ([ID])
);
GO
CREATE CLUSTERED INDEX [IC_dbo.ClientStudyClaimPeople(ID_CLAIM)] ON [dbo].[ClientStudyClaimPeople] ([ID_CLAIM] ASC);
GO

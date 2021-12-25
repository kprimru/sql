USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ClientStatDetailAVG]
(
        [id]                    Int                Identity(1,1)   NOT NULL,
        [UpDate]                DateTime                           NOT NULL,
        [WeekID]                UniqueIdentifier                   NOT NULL,
        [Net]                   NVarChar(512)                      NOT NULL,
        [ComplCount]            Int                                NOT NULL,
        [ComplNoEnt]            Int                                NOT NULL,
        [ComplWithEnt]          Int                                NOT NULL,
        [EntCount]              Int                                NOT NULL,
        [UserCount]             Int                                NOT NULL,
        [0Enter]                Int                                NOT NULL,
        [1Enter]                Int                                NOT NULL,
        [2Enter]                Int                                NOT NULL,
        [3Enter]                Int                                NOT NULL,
        [AVGUserCount]          float                              NOT NULL,
        [AVGWorkUserCount]      float                              NOT NULL,
        [AVGNWorkUserCount]     float                              NOT NULL,
        [AVGEntCount]           float                              NOT NULL,
        [AVGWorkUserEntCount]   float                              NOT NULL,
        [AVGSessionTime]        float                              NOT NULL,
        CONSTRAINT [PK_dbo.ClientStatDetailAVG] PRIMARY KEY CLUSTERED ([id]),
        CONSTRAINT [FK_dbo.ClientStatDetailAVG(WeekID)_dbo.Period(ID)] FOREIGN KEY  ([WeekID]) REFERENCES [Common].[Period] ([ID])
);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_dbo.ClientStatDetailAVG(WeekID,Net)] ON [dbo].[ClientStatDetailAVG] ([WeekID] ASC, [Net] ASC);
GO
